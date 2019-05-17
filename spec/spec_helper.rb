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

try_server = proc do |uri|
  begin
    response = Net::HTTP.get_response uri
    response.code != "503"
  rescue Errno::ECONNREFUSED
  end
end

start_server = proc do |timeout|
  server = Sunspot::Rails::Server.new
  uri = URI.parse("http://0.0.0.0:#{server.port}/solr/default/update?wt=json")

  try_server[uri] or begin
    server.start
    at_exit { server.stop }

    timeout.times.any? do
      sleep 1
      try_server[uri]
    end
  end
end

original_session = nil
sunspot_server = nil

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

  config.before(:each) do |example|
    if example.metadata[:solr]
      sunspot_server ||= start_server[60] || raise("SOLR connection timeout")
    else
      original_session = Sunspot.session
      Sunspot.session = Sunspot::Rails::StubSessionProxy.new(original_session)
    end
  end

  config.after(:each) do |example|
    if example.metadata[:solr]
      Sunspot.remove_all!
    else
      Sunspot.session = original_session
    end

    original_session = nil
  end

  config.filter_run(focus: true)
  config.run_all_when_everything_filtered = true
  config.infer_spec_type_from_file_location!
end
