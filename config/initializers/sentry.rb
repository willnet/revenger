Sentry.init do |config|
  config.dsn = Rails.application.credentials.dig(:sentry, :dsn)
  config.traces_sampler = lambda do |sampling_context|
    transaction_name = sampling_context[:transaction_context][:name]
    next 0.0 if transaction_name == "Rails::HealthController#show"

    0.1
  end
  config.enabled_environments = %w[production]
  config.enable_logs = true
  config.enabled_patches << :logger
end
