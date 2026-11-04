# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Sprockets 3 は importmap の pin をプリコンパイル対象として検出しない。
# 起動後に追加したファイルも開発中に解決できるよう、ファイル一覧ではなく条件で指定する。
javascript_path = "#{Rails.root.join('app/javascript')}/"
Rails.application.config.assets.precompile << ->(_logical_path, filename) { filename.start_with?(javascript_path) }
Rails.application.config.assets.precompile += %w(stimulus-loading.js)
