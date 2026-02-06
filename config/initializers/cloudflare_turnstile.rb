RailsCloudflareTurnstile.configure do |c|
  # In development/test, use mock if env vars not set
  # In production, require real credentials
  if Rails.env.production?
    c.site_key = ENV.fetch('CLOUDFLARE_TURNSTILE_SITE_KEY')
    c.secret_key = ENV.fetch('CLOUDFLARE_TURNSTILE_SECRET_KEY')
  else
    c.site_key = ENV.fetch('CLOUDFLARE_TURNSTILE_SITE_KEY', '1x00000000000000000000AA')
    c.secret_key = ENV.fetch('CLOUDFLARE_TURNSTILE_SECRET_KEY', '1x0000000000000000000000000000000AA')
  end
  c.fail_open = true
end
