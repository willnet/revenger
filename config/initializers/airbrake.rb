Airbrake.configure do |c|
  c.project_id = 51637
  c.project_key = ENV['AIRBRAKE_API_KEY']
  c.ignore_environments = %i(development test)
end
