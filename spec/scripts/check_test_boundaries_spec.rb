require 'rspec'
require 'rbconfig'
require 'stringio'
require 'timeout'
require_relative '../../scripts/check_test_boundaries'

RSpec.describe BoundaryChecks do
  around do |example|
    Dir.mktmpdir('boundary-spec-') do |directory|
      @root = directory
      example.run
    end
  end

  def write(path, contents = 'original')
    file = File.join(@root, path)
    FileUtils.mkdir_p(File.dirname(file))
    File.write(file, contents)
    file
  end

  def report(**changes)
    counts = BoundaryChecks::Report::COUNTS.to_h { |key| [key, 0] }
    { 'summary' => counts.merge('total' => 1, 'attempted' => 1, 'killed' => 1, 'score' => 100).merge(changes.transform_keys(&:to_s)), 'ignored' => [] }
  end

  def runner
    BoundaryChecks::Runner.new(@root)
  end

  def cache(data = report)
    contents = JSON.generate(data)
    write('.mutineer/boundary-report.json', contents)
    fingerprint = BoundaryChecks::Snapshot.digest(BoundaryChecks::Snapshot.capture(@root))
    write('.mutineer/boundary-check.json', JSON.generate('fingerprint' => fingerprint,
      'report_sha256' => Digest::SHA256.hexdigest(contents)))
    fingerprint
  end

  def cli(*args, payload: {})
    output = StringIO.new
    status = described_class.main(args, input: StringIO.new(JSON.generate(payload)), output: output, root: @root)
    expect(status).to eq 0
    JSON.parse(output.string)
  end

  describe 'change selection and cache invalidation' do
    %w[app/models/post.rb app/contexts/create_post_context.rb spec/models/post_spec.rb
      spec/contexts/create_post_context_spec.rb spec/support/helpers.rb spec/fabricators/post.rb
      config/credentials.yml.enc config/database.yml config/initializers/example.rb db/schema.rb
      db/migrate/example.rb lib/example.rb lib/tasks/example.rake Gemfile .mutineer.yml].each do |path|
      it "invalidates a successful check for #{path}" do
        write('.mutineer.yml', '{}')
        write(path, path == '.mutineer.yml' ? '{}' : 'original')
        fingerprint = cache
        expect(runner.checked?(fingerprint)).to be true
        write(path, path == '.mutineer.yml' ? 'jobs: 1' : 'changed')
        after = BoundaryChecks::Snapshot.digest(BoundaryChecks::Snapshot.capture(@root))
        expect(after).not_to eq fingerprint
        expect(runner.checked?(after)).to be false
      end
    end

    %w[spec/system/example_spec.rb config/deploy.yml config/deploy/production.yml README.md
      app/models/.mutineer_mutant123.rb].each do |path|
      it "does not require a run or invalidate cache for #{path}" do
        expect(BoundaryChecks::Snapshot.relevant?(path)).to be false
        before = BoundaryChecks::Snapshot.capture(@root)
        write(path)
        expect(BoundaryChecks::Snapshot.capture(@root)).to eq before
        File.unlink(File.join(@root, path))
        expect(BoundaryChecks::Snapshot.capture(@root)).to eq before
      end
    end

    it 'detects a new spec and a source moved outside the scope without using Git' do
      file = write('app/models/post.rb')
      before = BoundaryChecks::Snapshot.capture(@root)
      FileUtils.mkdir_p(File.join(@root, 'notes'))
      File.rename(file, File.join(@root, 'notes/post.rb'))
      expect(BoundaryChecks::Snapshot.capture(@root)).not_to eq before
      write('spec/models/new_spec.rb')
      expect(BoundaryChecks::Snapshot.capture(@root)).to have_key('spec/models/new_spec.rb')
    end
  end

  describe 'report validation' do
    it 'accepts only explicitly reviewed equivalent IDs' do
      data = report(total: 2, ignored: 1)
      data['ignored'] = [{ 'id' => 'equivalent' }]
      expect(BoundaryChecks::Report.problem(data, status: 0, approved: { 'equivalent' => 'Same result for supported inputs' })).to be_nil
      expect(BoundaryChecks::Report.problem(data, status: 0)).to include('承認されていない')
    end

    it 'accepts a fully reviewed equivalent scope but not an empty scope' do
      data = report(total: 1, attempted: 0, killed: 0, score: nil, ignored: 1)
      data['ignored'] = [{ 'id' => 'equivalent' }]
      expect(BoundaryChecks::Report.problem(data, status: 0, approved: { 'equivalent' => 'reason' })).to be_nil
      expect(BoundaryChecks::Report.problem(report(total: 0, attempted: 0, killed: 0, score: nil), status: 0)).to include('変異がありません')
    end

    [[], nil, { 'summary' => [] }, { 'summary' => {} }].each do |invalid|
      it "rejects invalid report shape #{invalid.inspect}" do
        expect(BoundaryChecks::Report.problem(invalid, status: 0)).to be_a(String)
      end
    end

    [nil, '1', true, -1].each do |invalid|
      it "rejects invalid counts #{invalid.inspect}" do
        expect(BoundaryChecks::Report.problem(report(attempted: invalid), status: 0)).to include('件数が不正')
      end
    end

    BoundaryChecks::Report::FAILURES.each do |field|
      it "reports #{field} even when the process exits 1" do
        expect(BoundaryChecks::Report.problem(report(**{ field.to_sym => 1 }), status: 1)).to include("#{field}=1")
      end
    end

    it 'runs validation on cached content whose hash still matches' do
      write('.mutineer.yml', '{}')
      fingerprint = cache(report(survived: 1))
      expect(runner.checked?(fingerprint)).to be false
      fingerprint = cache
      expect(runner.checked?(fingerprint)).to be true
      write('.mutineer/boundary-report.json', '{}')
      expect(runner.checked?(fingerprint)).to be false
    end

    it 'rejects reasonless suppression entries in configuration' do
      ["ignore: [some-id]", "ignore:\n  - id: some-id\n    reason: ''"].each do |contents|
        write('.mutineer.yml', contents)
        expect { BoundaryChecks.approved_ignores(@root) }.to raise_error(BoundaryChecks::Error, /reason/)
      end
    end
  end

  describe 'prompt and completion hooks' do
    let(:payload) { { 'session_id' => 'session', 'stop_hook_active' => false } }

    before do
      write('.mutineer.yml', '{}')
      write('.git', 'gitdir: /missing/host/worktree')
      write('app/models/post.rb')
    end

    it 'allows read-only turns with existing branch changes and no working Git metadata' do
      cli('--hook-start', payload: payload)
      expect(cli('--hook-stop', payload: payload)).to eq({})
    end

    it 'requests a run for spec-only edits, preserves pending across continuation, and does not loop' do
      cli('--hook-start', payload: payload)
      write('spec/models/post_spec.rb')
      expect(cli('--hook-stop', payload: payload)['decision']).to eq('block')
      cli('--hook-start', payload: payload)
      expect(cli('--hook-stop', payload: payload.merge('stop_hook_active' => true))).to have_key('systemMessage')
      cli('--hook-start', payload: payload)
      expect(cli('--hook-stop', payload: payload)).to eq({})
    end

    it 'allows completion after a matching successful check' do
      cli('--hook-start', payload: payload)
      write('spec/models/post_spec.rb')
      cache
      expect(cli('--hook-stop', payload: payload)).to eq({})
    end

    it 'reports an unknown baseline without claiming the source was checked' do
      expect(cli('--hook-stop', payload: payload)['systemMessage']).to include('スナップショットがありません')
    end

    [[], nil, { 'session_id' => nil }].each do |invalid|
      it "returns a blocking JSON response for invalid hook input #{invalid.inspect}" do
        expect(cli('--hook-stop', payload: invalid)['decision']).to eq('block')
      end
    end

    it 'returns a blocking JSON response for unexpected validation errors' do
      allow(BoundaryChecks::Hooks).to receive(:new).and_raise(TypeError, 'invalid input')
      expect(cli('--hook-stop', payload: payload)['decision']).to eq('block')
    end
  end

  describe 'runner process isolation' do
    it 'does not leave a successful record after a crash and preserves the real error log' do
      write('.mutineer.yml', '{}')
      cache
      expect {
        runner.run(command: [RbConfig.ruby, '-e', 'warn "cannot boot database"; exit 2'])
      }.to raise_error(BoundaryChecks::Error, /起動・実行に失敗/)
      expect(File).not_to exist(runner.path('boundary-check.json'))
      expect(File.read(runner.path('boundary-run.log'))).to include('cannot boot database')
    end

    it 'keeps the lock in the child after its runner is killed' do
      write('.mutineer.yml', '{}')
      child_pid_path = File.join(@root, 'child.pid')
      release_path = File.join(@root, 'release')
      child = "File.write(ARGV[0], Process.pid.to_s); sleep 0.02 until File.exist?(ARGV[1])"
      parent = fork do
        runner.run(command: [RbConfig.ruby, '-e', child, child_pid_path, release_path])
        exit! 0
      end
      Timeout.timeout(5) { sleep 0.01 until File.file?(child_pid_path) }
      worker = Integer(File.read(child_pid_path))
      Process.kill('KILL', parent)
      Process.wait(parent)
      parent = nil
      expect { runner.run(command: [RbConfig.ruby, '-e', 'exit 0']) }.to raise_error(BoundaryChecks::Error, /実行中/)
      File.write(release_path, '')
      Timeout.timeout(5) do
        File.open(runner.path('boundary-check.lock'), 'w') do |lock|
          sleep 0.01 until lock.flock(File::LOCK_EX | File::LOCK_NB)
        end
      end
    ensure
      if parent
        Process.kill('KILL', parent) rescue nil
        Process.wait(parent) rescue nil
      end
      Process.kill('KILL', worker) rescue nil if worker
    end
  end

  describe 'CI selection' do
    def git(*args)
      stdout, stderr, status = Open3.capture3('git', *args, chdir: @root)
      raise stderr unless status.success?
      stdout.strip
    end

    it 'skips documentation but detects the old path when a model is renamed out of scope' do
      git('init', '-q')
      write('app/models/post.rb')
      git('add', '.')
      git('-c', 'user.name=Boundary Tests', '-c', 'user.email=boundary@example.test', 'commit', '-qm', 'initial')
      base = git('rev-parse', 'HEAD')
      write('README.md')
      git('add', '.')
      git('-c', 'user.name=Boundary Tests', '-c', 'user.email=boundary@example.test', 'commit', '-qm', 'docs')
      expect(BoundaryChecks.ci_relevant?(@root, base)).to be false
      FileUtils.mkdir_p(File.join(@root, 'notes'))
      git('mv', 'app/models/post.rb', 'notes/post.rb')
      git('-c', 'user.name=Boundary Tests', '-c', 'user.email=boundary@example.test', 'commit', '-qm', 'move')
      expect(BoundaryChecks.ci_relevant?(@root, base)).to be true
    end

    it 'does not silently skip a missing comparison ref' do
      expect { BoundaryChecks.ci_relevant?(@root, nil) }.to raise_error(BoundaryChecks::Error, /比較元/)
    end
  end
end
