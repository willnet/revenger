set :user, 'maeshima'
set :domain, 'revenger.in'
set :rails_env, 'production'
set :bundle_without, [:staging, :development, :test, :darwin]
set :branch, 'master'
role :web, domain
role :app, domain
role :db,  domain, :primary => true
