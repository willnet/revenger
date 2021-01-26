Sentry.init do |config|
  config.dsn = 'https://2380a59dcae846718fab493ef71bcae3:941bfe07535e4e4d8793d87bfc874028@sentry.io/292312'
  config.traces_sample_rate = 0.2
  config.enabled_environments = %w[production]
end
