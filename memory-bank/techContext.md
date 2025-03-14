# 技術コンテキスト

## 開発環境
- Ruby 2.6.6
- Rails 5.2.4.1
- Docker/Docker Compose
- SQLite（開発・テスト環境）

## フロントエンド
- HAML（テンプレートエンジン）
- SASS（スタイルシート）
- Bootstrap（CSSフレームワーク）
- jQuery（JavaScript）
- CoffeeScript

## バックエンド
- Ruby on Rails
- Devise（認証）
- Kaminari（ページネーション）

## テスト
- RSpec（テストフレームワーク）
- Capybara（統合テスト）
- Selenium WebDriver（JavaScriptテスト）
- Chromium（ヘッドレスブラウザ）
- DatabaseRewinder（テストデータクリーンアップ）
- Fabrication（テストデータ作成）

## インフラ
- Docker/Docker Compose（開発環境）
- Unicorn（アプリケーションサーバー）
- Capistrano（デプロイ）

## 重要な設定ファイル
- `spec/spec_helper.rb` - テスト設定
- `config/initializers/webdrivers.rb` - Webドライバー設定
- `Dockerfile` - Dockerイメージ設定
- `docker-compose.yml` - Docker Compose設定

## ChromeDriverの設定
- Dockerコンテナ内では、ChromeDriverは`/usr/bin/chromedriver`にインストールされています
- Chromiumのバイナリは`/usr/bin/chromium`にインストールされています
- テスト実行時は、`RAILS_ENV=test`を設定する必要があります

## テスト実行方法
```bash
# Dockerコンテナ内でテストを実行
docker compose run --rm app bash
RAILS_ENV=test bundle exec rspec spec/features/
