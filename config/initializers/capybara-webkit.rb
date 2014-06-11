if Rails.env.test?
  Rails.application.config.assets.paths.reject! { |path| path.to_s =~ /font-awesome/ }
end
