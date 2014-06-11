set :user, 'jenkins'
set :domain, 'localhost'
set :rails_env, 'staging'
set :bundle_without, [:production, :development, :test, :darwin]
set :branch, 'master'
role :web, domain
role :app, domain
role :db,  domain, :primary => true

