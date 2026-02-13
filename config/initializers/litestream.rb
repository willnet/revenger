Rails.application.configure do
  litestream_credentials = Rails.application.credentials.litestream || {}

  # Populate litestream-ruby managed ENV values from Rails credentials.
  config.litestream.replica_bucket = litestream_credentials[:replica_bucket]
  config.litestream.replica_region = litestream_credentials[:replica_region]
  config.litestream.replica_key_id = litestream_credentials[:replica_key_id]
  config.litestream.replica_access_key = litestream_credentials[:replica_access_key]

  # Replica path prefix is app-specific, so pass it explicitly as an ENV value.
  if litestream_credentials[:replica_path_prefix].present?
    ENV["LITESTREAM_REPLICA_PATH_PREFIX"] = litestream_credentials[:replica_path_prefix]
  end

  config.litestream.config_path = Rails.root.join("config", "litestream.yml")
end
