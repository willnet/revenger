require 'digest'
require 'fileutils'
require 'json'
require 'open3'
require 'optparse'
require 'tempfile'
require 'yaml'

module BoundaryChecks
  class Error < StandardError; end

  class Snapshot
    PATTERNS = %w[app/**/*.rb lib/**/*.rb lib/**/*.rake db/**/*.rb db/**/*.sql
      spec/models/**/*.rb spec/contexts/**/*.rb spec/support/**/*.rb spec/fabricators/**/*.rb
      spec/scripts/**/*.rb spec/spec_helper.rb config/**/* Gemfile Gemfile.lock .rspec
      .mutineer.yml bin/mutineer scripts/check_test_boundaries.rb].freeze

    def self.relevant?(path)
      return false if File.basename(path).start_with?('.mutineer_mutant')
      return false if path == 'config/deploy.yml' || path.start_with?('config/deploy/')

      PATTERNS.any? { |pattern| File.fnmatch?(pattern, path, File::FNM_PATHNAME | File::FNM_EXTGLOB | File::FNM_DOTMATCH) }
    end

    def self.capture(root)
      Dir.chdir(root) do
        Dir.glob(PATTERNS, File::FNM_DOTMATCH).uniq.sort.each_with_object({}) do |path, files|
          files[path] = Digest::SHA256.file(path).hexdigest if relevant?(path) && File.file?(path)
        end
      end
    end

    def self.digest(files)
      Digest::SHA256.hexdigest(JSON.generate(files.sort.to_h))
    end
  end

  def self.read_json(path)
    JSON.parse(File.read(path))
  end

  def self.write_json(path, value)
    FileUtils.mkdir_p(File.dirname(path))
    Tempfile.create(['boundary-', '.json'], File.dirname(path)) do |file|
      file.write(JSON.generate(value))
      file.close
      File.rename(file.path, path)
    end
  end

  def self.approved_ignores(root)
    config = YAML.safe_load(File.read(File.join(root, '.mutineer.yml'))) || {}
    raise Error, '.mutineer.yml はオブジェクトで指定してください。' unless config.is_a?(Hash)

    entries = config.fetch('ignore', [])
    raise Error, 'ignore は理由付きのID一覧で指定してください。' unless entries.is_a?(Array)

    entries.to_h do |entry|
      unless entry.is_a?(Hash) && entry['id'].is_a?(String) && !entry['id'].strip.empty? &&
          entry['reason'].is_a?(String) && !entry['reason'].strip.empty?
        raise Error, '等価変異の ignore には id とレビュー可能な reason が必要です。'
      end
      [entry['id'], entry['reason']]
    end
  end

  class Report
    COUNTS = %w[total attempted killed survived no_coverage uncapturable unplaceable ran_at_load errored timeout no_verdict ignored].freeze
    FAILURES = %w[survived no_coverage uncapturable unplaceable ran_at_load errored timeout no_verdict].freeze

    def self.problem(data, status:, approved: {})
      return 'Mutineer のJSONレポートが不正です。' unless data.is_a?(Hash) && data['summary'].is_a?(Hash)
      summary = data['summary']
      unless COUNTS.all? { |key| summary[key].is_a?(Integer) && summary[key] >= 0 }
        return 'Mutineer の集計件数が不正です（未設定・null・負数は許可しません）。'
      end
      failures = FAILURES.filter_map { |key| "#{key}=#{summary[key]}" if summary[key].positive? }
      return "変異チェックが未完了です: #{failures.join(', ')}。boundary-report.json を確認してください。" unless failures.empty?

      ignored = data['ignored']
      unless ignored.is_a?(Array) && ignored.size == summary['ignored'] &&
          ignored.all? { |entry| entry.is_a?(Hash) && approved.key?(entry['id']) }
        return '理由付きで承認されていない除外があります。.mutineer.yml の id / reason を確認してください。'
      end
      return "Mutineer が異常終了しました（終了コード #{status.inspect}）。boundary-run.log を確認してください。" unless status == 0
      if summary['attempted'].zero?
        return nil if summary['total'].positive? && summary['total'] == ignored.size
        return '採点できる変異がありません。対象・設定を確認し、境界値を別途レビューしてください。'
      end
      score = summary['score']
      return '変異スコアが不正です。' unless score.is_a?(Numeric) && score.finite? && score.between?(0, 100)
      nil
    end
  end

  class Runner
    attr_reader :root, :directory

    def initialize(root)
      @root = File.expand_path(root)
      @directory = File.join(@root, '.mutineer')
    end

    def path(name)
      File.join(directory, name)
    end

    def checked?(fingerprint)
      state = BoundaryChecks.read_json(path('boundary-check.json'))
      return false unless state.is_a?(Hash) && state['fingerprint'] == fingerprint
      contents = File.read(path('boundary-report.json'))
      state['report_sha256'] == Digest::SHA256.hexdigest(contents) &&
        Report.problem(JSON.parse(contents), status: 0, approved: BoundaryChecks.approved_ignores(root)).nil?
    rescue Errno::ENOENT, JSON::ParserError, Error, Psych::Exception
      false
    end

    def command
      args = [File.join(root, 'bin/mutineer'), 'run', 'app/models', 'app/contexts', '--no-since',
        '--no-fail-fast', '--threshold', '100', '--format', 'json', '--output', '.mutineer/boundary-report.json']
      Dir.glob(File.join(root, 'spec/{models,contexts}/**/*_spec.rb')).sort.each do |spec|
        args.concat(['--test', spec.delete_prefix(root + '/')])
      end
      args
    end

    def run(command: self.command)
      FileUtils.mkdir_p(directory)
      File.open(path('boundary-check.lock'), 'w') do |lock|
        raise Error, '別の境界値チェックがコンテナ内で実行中です。完了を待ってください。' unless lock.flock(File::LOCK_EX | File::LOCK_NB)
        FileUtils.rm_f(path('boundary-check.json'))
        FileUtils.rm_f(path('boundary-report.json'))
        approved = BoundaryChecks.approved_ignores(root)
        before = Snapshot.digest(Snapshot.capture(root))
        File.open(path('boundary-run.log'), 'w') do |log|
          # The child must keep the lock if the launcher is killed while container work continues.
          lock.close_on_exec = false
          pid = Process.spawn(*command, chdir: root, out: log, err: [:child, :out], lock.fileno => lock.fileno)
          _, status = Process.wait2(pid)
          unless status.success? || File.file?(path('boundary-report.json'))
            raise Error, "Mutineer が起動・実行に失敗しました（#{status.inspect}）。#{path('boundary-run.log')} を確認してください。"
          end
          raise Error, '実行中に対象ファイルが変更されました。再実行してください。' unless before == Snapshot.digest(Snapshot.capture(root))
          raise Error, 'Mutineer がレポートを生成しませんでした。boundary-run.log を確認してください。' unless File.file?(path('boundary-report.json'))
          contents = File.read(path('boundary-report.json'))
          problem = Report.problem(JSON.parse(contents), status: status.exitstatus, approved: approved)
          raise Error, problem if problem
          BoundaryChecks.write_json(path('boundary-check.json'), {
            'fingerprint' => before, 'report_sha256' => Digest::SHA256.hexdigest(contents)
          })
        end
      end
      puts '境界値の自動変異チェックが完了しました。定数・SQL等の境界は別途確認してください。'
      0
    end
  end

  class Hooks
    def initialize(runner)
      @runner = runner
    end

    def call(event, payload)
      raise Error, 'フック入力はオブジェクトで指定してください。' unless payload.is_a?(Hash)
      session = payload['session_id']
      raise Error, 'フック入力に session_id が必要です。' unless session.is_a?(String) && !session.empty?
      state_path = @runner.path("sessions/#{Digest::SHA256.hexdigest(session)}.json")
      state = File.file?(state_path) ? BoundaryChecks.read_json(state_path) : {}
      raise Error, 'フックの確認記録が不正です。' unless state.is_a?(Hash)
      current = Snapshot.capture(@runner.root)
      if event == :start
        state['baseline'] = current
        BoundaryChecks.write_json(state_path, state)
        return {}
      end
      unless state['baseline'].is_a?(Hash)
        return { 'systemMessage' => '開始時の境界値スナップショットがありません。次の入力から変更を検出します。' }
      end
      changed = state['baseline'] != current || (payload['stop_hook_active'] == true && state['pending'] == true)
      pending = changed && !@runner.checked?(Snapshot.digest(current))
      state.merge!('baseline' => current, 'pending' => pending)
      BoundaryChecks.write_json(state_path, state)
      return {} unless pending
      message = '境界値チェックが未完了です。bin/check-test-boundaries --run を実行し、.mutineer/boundary-report.json と boundary-run.log を確認してください。妥当なテストを補強し、定数・SQLの境界も確認してください。等価変異は理由付きでレビューし、解決できない場合は理由を報告してください。'
      return { 'systemMessage' => message } if payload['stop_hook_active'] == true
      { 'decision' => 'block', 'reason' => message }
    end
  end

  def self.ci_relevant?(root, base)
    raise Error, 'CIの比較元 BOUNDARY_BASE_REF が必要です。' if base.nil? || base.empty?
    output, error, status = Open3.capture3('git', 'diff', '--no-renames', '--name-only', '-z', "#{base}...HEAD", '--', chdir: root)
    raise Error, "CIの変更範囲を取得できません: #{error.strip}" unless status.success?
    output.split("\0").any? { |path| Snapshot.relevant?(path) }
  end

  def self.main(arguments, input: $stdin, output: $stdout, error: $stderr, root: File.expand_path('..', __dir__))
    options = {}
    OptionParser.new do |parser|
      parser.on('--run') { options[:run] = true }
      parser.on('--local') { }
      parser.on('--ci') { options[:ci] = true; options[:run] = true }
      parser.on('--hook-start') { options[:event] = :start }
      parser.on('--hook-stop') { options[:event] = :stop }
    end.parse!(arguments)
    runner = Runner.new(root)
    if options[:run]
      if options[:ci] && !ci_relevant?(root, ENV['BOUNDARY_BASE_REF'])
        output.puts '境界値チェックに関連する変更がないため、変異解析を省略します。'
        return 0
      end
      return runner.run
    end
    raise Error, '--run / --ci / --hook-start / --hook-stop を指定してください。' unless options[:event]
    payload = JSON.parse(input.read)
    output.puts JSON.generate(Hooks.new(runner).call(options[:event], payload))
    0
  rescue StandardError => exception
    message = "境界値チェックに失敗しました: #{exception.message}"
    if options && options[:event]
      continued = payload.is_a?(Hash) && payload['stop_hook_active'] == true
      response = options[:event] == :start || continued ? { 'systemMessage' => message } : { 'decision' => 'block', 'reason' => message }
      output.puts JSON.generate(response)
      0
    else
      error.puts message
      1
    end
  end
end

exit BoundaryChecks.main(ARGV) if $PROGRAM_NAME == __FILE__
