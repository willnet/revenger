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
Capybara::Screenshot
  .register_driver(:selenium_chrome_headless) do |driver, path|
  driver.browser.save_screenshot(path)
end

require 'sunspot/rails/spec_helper'
require 'net/http'

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
    Sunspot.remove_all!
  end

  config.filter_run(focus: true)
  config.run_all_when_everything_filtered = true
  config.infer_spec_type_from_file_location!
end
