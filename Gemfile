# -*- coding: utf-8 -*-
source 'http://rubygems.org'

gem 'rails', '4.1.5'
gem 'mysql2'
gem 'unicorn'
gem 'rabl'
gem 'i18n-js'
gem 'roadie', '~> 2.4'
gem 'kaminari'
gem 'sunspot_with_kaminari'
gem 'redcarpet'
gem 'pygments.rb', require: 'pygments'
gem 'airbrake'
gem 'newrelic_rpm'
gem 'devise'
gem 'therubyracer'
gem 'haml-rails'
gem 'capistrano', require: false
gem 'capistrano-unicorn', require: false
gem 'whenever', :require => false
gem 'sunspot_rails', '2.1.0'
gem 'jquery-rails'
gem 'dotenv-rails'
gem 'dotenv-deployment'

group :assets do
  gem 'coffee-script-source', '1.6.2'
  gem 'sass-rails', '~> 4.0.3'
  gem 'coffee-rails', '~> 4.0.0'
  gem 'uglifier'
  gem 'haml_coffee_assets'
  gem 'execjs'
  gem 'bootstrap-sass', github: 'willnet/bootstrap-sass'
  gem 'compass-rails'
  gem 'zurui-sass-rails'
end

group :development, :test do
  gem 'annotate'
  gem 'i18n_generators'
  gem 'rspec-rails'
  gem 'pry-rails'
  gem 'pry-remote'
  gem 'pry-nav'
  gem 'pry-doc'
  gem 'sunspot_solr'
  gem 'guard-rspec'
  gem 'guard-bundler'
  gem 'guard-pow'
  gem 'ci_reporter'
end

group :development do
  gem 'better_errors'
  gem "binding_of_caller"
  gem 'meta_request'
  gem 'letter_opener'
end

group :test do
  gem 'sunspot-rails-tester'
  gem 'rake_shared_context'
  gem 'database_cleaner'
  gem 'timecop'
  gem 'capybara'
  gem 'capybara-webkit'
  gem 'capybara-email'
  gem 'headless'
  gem 'fabrication'
  gem 'accept_values_for'
  gem 'launchy'
  gem 'simplecov', require: false
  gem 'simplecov-rcov', require: false
  gem 'rspec-its'
end

group :darwin do
  gem 'rb-fsevent', require: false
  gem 'growl'
end
