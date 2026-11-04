# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Sprockets 3 は importmap の pin をプリコンパイル対象として検出しない。
javascript_path = Rails.root.join('app/javascript')
Rails.application.config.assets.precompile += Dir[javascript_path.join('**/*.js')].map do |path|
  Pathname.new(path).relative_path_from(javascript_path).to_s
end
Rails.application.config.assets.precompile += %w(stimulus-loading.js)
