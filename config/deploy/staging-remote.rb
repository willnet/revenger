set :user, 'jenkins'
set :domain, 'jenkinsjenkins'
set :rails_env, 'staging'
set :bundle_without, [:production, :development, :test, :darwin]
set :branch, 'develop'
role :web, domain
role :app, domain
role :db,  domain, :primary => true
