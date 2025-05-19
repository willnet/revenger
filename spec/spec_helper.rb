ENV["RAILS_ENV"] ||= 'test'

require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'capybara/rails'
require 'capybara/rspec'
require 'capybara/email/rspec'
require 'accept_values_for'

Capybara.server_port = 3001

def create_options
  remote_debug = ENV.fetch('REMOTE_DEBUG', false)
  options = Selenium::WebDriver::Chrome::Options.new(logging_prefs: { browser: 'ALL' })
  options.add_argument('--headless=new')
  options.add_argument('--disable-gpu')
  options.add_argument('--disable-dev-shm-usage')
  options.add_argument('--no-sandbox')
  options.add_argument('--ignore-certificate-errors')
  options.add_argument('--remote-debugging-port=9222') if remote_debug
  options.add_argument('--remote-debugging-address=0.0.0.0') if remote_debug
  options
end

# https://github.com/teamcapybara/capybara/blob/master/lib/capybara.rb#L477-L482
Capybara.register_driver :selenium_chrome_headless do |app|
  Capybara::Selenium::Driver.new(
    app, browser: :chrome, timeout: 600, options: create_options
  )
end

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  config.mock_with :rspec
  config.use_transactional_fixtures = true
  config.before(:example, type: :system) do |example|
    driven_by :selenium_chrome_headless
  end

  config.before(:each) do
    ActionMailer::Base.deliveries.clear
  end

  config.after(:each) do
    Timecop.return
  end

  config.filter_run(focus: true)
  config.run_all_when_everything_filtered = true
  config.infer_spec_type_from_file_location!
end
