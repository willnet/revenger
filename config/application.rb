require File.expand_path('../boot', __FILE__)
require 'rails'

require 'active_model/railtie'
require 'active_job/railtie'
require 'active_record/railtie'
# require "active_storage/engine"
require 'action_controller/railtie'
require 'action_mailer/railtie'
# require "action_mailbox/engine"
# require "action_text/engine"
require 'action_view/railtie'
# require "action_cable/engine"
# require 'rails/test_unit/railtie'

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
