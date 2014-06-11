#!/usr/bin/env rake
# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)

ENV['CI_REPORTS'] = Dir.pwd + '/reports'
begin
  require 'ci/reporter/rake/rspec'
rescue LoadError
end

Revenger::Application.load_tasks

if defined? Rspec
  desc 'Run factory specs.'
  RSpec::Core::RakeTask.new(:fabrications_specs) do |t|
    t.pattern = './spec/fabrications_spec.rb'
  end
  task spec: :fabrications_specs
end
