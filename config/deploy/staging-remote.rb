set :user, 'jenkins'
set :domain, 'dev.revenger.in'
set :rails_env, 'staging'
set :bundle_without, [:production, :development, :test, :darwin]
set :branch, 'develop'
role :web, domain
role :app, domain
role :db,  domain, :primary => true
