RailsCloudflareTurnstile.configure do |c|
  # In development/test, use mock if env vars not set
  # In production, require real credentials
  if Rails.env.production?
    c.site_key = Rails.application.credentials.dig(:cloudflare_turnstile, :site_key)
    c.secret_key = Rails.application.credentials.dig(:cloudflare_turnstile, :secret_key)
  else
    c.site_key = 'dummy_site_key' # Dummy key for development/test
    c.secret_key = 'dummy_secret_key' # Dummy key for development/test
  end
  c.fail_open = true
  c.enabled = !Rails.env.local? && !ENV["SECRET_KEY_BASE_DUMMY"]
end
