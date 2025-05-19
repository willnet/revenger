# 技術コンテキスト

## 開発環境
- Ruby 2.7.8
- Rails 6.0
- Docker/Docker Compose
- VSCode devcontainer（開発環境の一貫性とセットアップの簡易化）
- SQLite（開発・テスト環境）

## フロントエンド
- HAML（テンプレートエンジン）
- SASS（スタイルシート）
- Bootstrap（CSSフレームワーク）
- jQuery（JavaScript）
- JavaScript（CoffeeScriptから移行中）

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
- VSCode devcontainer（開発環境の標準化）
- Puma（アプリケーションサーバー）
- Capistrano（デプロイ）

## 重要な設定ファイル
- `spec/spec_helper.rb` - テスト設定
- `config/initializers/webdrivers.rb` - Webドライバー設定
- `Dockerfile` - Dockerイメージ設定
- `docker-compose.yml` - Docker Compose設定
- `.devcontainer/` - VSCode devcontainer設定
- `app/assets/javascripts/application.js` - JavaScriptアセット設定

## フロントエンド移行状況
- CoffeeScriptファイル（`.coffee`）はすべてJavaScriptファイル（`.js`）に変換済み
- HAMLCoffeeテンプレート（`.hamlc`）はまだ変換が必要
- `application.js`の`require hamlcoffee`の依存関係を解決する必要あり

## ChromeDriverの設定
- Dockerコンテナ内では、ChromeDriverは`/usr/bin/chromedriver`にインストールされています
- Chromiumのバイナリは`/usr/bin/chromium`にインストールされています
- テスト実行時は、`RAILS_ENV=test`を設定する必要があります

## 開発環境セットアップ
- VSCode devcontainerを使用して開発環境を一貫性のある状態で構築
- devcontainerにより、すべての開発者が同じ環境で作業可能
- VSCodeの拡張機能も自動的にインストールされ、開発体験が向上

## テスト実行方法
```bash
# Dockerコンテナ内でテストを実行
docker compose run --rm app bash
RAILS_ENV=test bundle exec rspec spec/system/
