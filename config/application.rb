require File.expand_path('../boot', __FILE__)
require 'rails/all'

Bundler.require(*Rails.groups)

module Revenger
  class Application < Rails::Application
    config.load_defaults 7.1
    config.eager_load_paths += [Rails.root.join('lib').to_s]
    config.time_zone = 'Tokyo'
    config.i18n.default_locale = :ja

    config.generators do |g|
      g.test_framework      :rspec, :fixture => true
      g.fixture_replacement :fabrication
      g.assets false
      g.helper false
      g.view_spec false
    end
  end
end

ActionView::Base.field_error_proc = Proc.new do |html_tag, instance|
  html_tag.html_safe
end
