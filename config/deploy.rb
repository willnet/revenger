set :whenever_command, "bundle exec whenever"
set :stages, %w(production staging staging-remote)
set :default_stage, 'staging'

require 'bundler/capistrano'
require "whenever/capistrano"
require 'capistrano/ext/multistage'
require 'capistrano-unicorn'
require 'dotenv/deployment/capistrano'

set :bundle_flags, "--deployment --quiet --binstubs"
set :application, "revenger"
set :repository, "git@github.com:willnet/revenger.git"

set :scm, :git

set :deploy_to, "/opt/revenger"
set :deploy_via, :export

set :unicorn_pid, "#{deploy_to}/shared/pids/unicorn.pid"

set :default_environment, {
  'PATH' => "/usr/local/rbenv/shims:/usr/local/rbenv/bin:$PATH"
}

namespace :deploy do
  task :link_database_setting do
    try_sudo "ln -nfs #{shared_path}/database.yml #{latest_release}/config/database.yml"
  end

  task :setup_config, roles: :app do
    try_sudo "ln -nfs #{current_path}/config/nginx.conf /usr/local/nginx/conf/nginx.conf"
  end

  after "deploy:setup", "deploy:setup_config"
end

namespace :yarn do
  task :install, roles: :app do
    run "cd #{latest_release} && yarn install"
  end
end

after "deploy:create_symlink" do
  try_sudo "chgrp -R staff #{shared_path}/"
end

before 'deploy:assets:precompile', 'deploy:link_database_setting'
before 'deploy:assets:precompile', 'yarn:install'

after 'deploy:update', 'deploy:cleanup'
after 'deploy:restart', 'unicorn:restart'

require './config/boot'
