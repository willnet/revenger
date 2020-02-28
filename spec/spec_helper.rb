ENV["RAILS_ENV"] ||= 'test'

require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'

require 'capybara/rails'
require 'capybara/rspec'
require 'capybara/email/rspec'
require 'capybara-screenshot/rspec'
require 'accept_values_for'
Capybara.javascript_driver = :selenium_chrome_headless
Capybara.server = :webrick
Capybara.server_port = 3001

Capybara.register_driver :selenium_chrome_headless do |app|
  browser_options = Selenium::WebDriver::Chrome::Options.new
  browser_options.args << '--headless'
  browser_options.args << '--disable-gpu'
  browser_options.args << '--no-sandbox'
  browser_options.args << '--disable-dev-shm-usage'
  browser_options.args << '--ignore-certificate-errors'

  Capybara::Selenium::Driver.new(
    app, browser: :chrome, options: browser_options, timeout: 600
  ).tap do |driver|
    driver.browser.manage.window.size = Selenium::WebDriver::Dimension.new(
      1920, 1080
    )
  end
end

Capybara::Screenshot
  .register_driver(:selenium_chrome_headless) do |driver, path|
  driver.browser.save_screenshot(path)
end

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

RSpec.configure do |config|
  config.mock_with :rspec
  config.use_transactional_fixtures = false

  config.before(:suite) do
    DatabaseRewinder.clean_all
  end

  config.before(:each) do
    ActionMailer::Base.deliveries.clear
  end

  config.after(:each) do
    DatabaseRewinder.clean
    Timecop.return
  end

  config.after(:each) do |example|
    Post.solr_remove_all_from_index! if example.metadata[:solr]
  end

  config.filter_run(focus: true)
  config.run_all_when_everything_filtered = true
  config.infer_spec_type_from_file_location!
end
