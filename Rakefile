#!/usr/bin/env rake
# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)

Revenger::Application.load_tasks

if defined? Rspec
  desc 'Run factory specs.'
  RSpec::Core::RakeTask.new(:fabrications_specs) do |t|
    t.pattern = './spec/fabrications_spec.rb'
  end
  task spec: :fabrications_specs
end

require 'coveralls/rake/task'
Coveralls::RakeTask.new