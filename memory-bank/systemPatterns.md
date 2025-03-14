# システムパターン

## アーキテクチャ
- Ruby on Railsの基本的なMVCアーキテクチャに従っています
- モデル（`app/models/`）：データとビジネスロジック
- ビュー（`app/views/`）：ユーザーインターフェース
- コントローラー（`app/controllers/`）：リクエスト処理

## 特殊なパターン
- Contextパターン：`app/contexts/`ディレクトリにビジネスロジックをカプセル化
  - `create_post_context.rb`
  - `update_post_context.rb`
  - `read_review_context.rb`
  - `send_assignment_mail_context.rb`

## テスト構造
- モデルテスト：`spec/models/`
- コントローラーテスト：`spec/controllers/`
- フィーチャーテスト：`spec/features/`
- コンテキストテスト：`spec/contexts/`

## JavaScriptテスト
- Capybaraと`selenium_chrome_headless`ドライバーを使用
- `js: true`タグが付いたテストはJavaScriptを実行
- Dockerコンテナ内でChromiumを使用してヘッドレステストを実行

## 重要な設定
### Capybara設定（`spec/spec_helper.rb`）
```ruby
Capybara.javascript_driver = :selenium_chrome_headless
Capybara.register_driver :selenium_chrome_headless do |app|
  browser_options = Selenium::WebDriver::Chrome::Options.new
  browser_options.args << '--headless'
  browser_options.args << '--disable-gpu'
  browser_options.args << '--no-sandbox'
  browser_options.args << '--disable-dev-shm-usage'
  browser_options.args << '--ignore-certificate-errors'
  browser_options.binary = '/usr/bin/chromium'

  service = Selenium::WebDriver::Service.chrome(path: '/usr/bin/chromedriver')

  Capybara::Selenium::Driver.new(
    app,
    browser: :chrome,
    options: browser_options,
    service: service,
    timeout: 600
  )
end
```

### WebDrivers設定（`config/initializers/webdrivers.rb`）
```ruby
module Webdrivers
  class ChromeFinder
    class << self
      def location
        '/usr/bin/chromium'
      end
    end
  end

  class Chromedriver
    class << self
      def driver_path
        '/usr/bin/chromedriver'
      end
    end
  end
end
