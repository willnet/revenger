# -*- coding: utf-8 -*-
class ApplicationController < ActionController::Base
  protect_from_forgery

  unless Rails.env.development?
    rescue_from Exception, with: :error500
    rescue_from ActiveRecord::RecordNotFound, with: :error404
  end

  before_filter :force_ssl
  layout 'common'

  def after_sign_in_path_for(user)
    review_path
  end

  def error404
    render 'error404', status: 404, formats: [:html]
  end

  def error500(ex)
    notify_airbrake(ex)
    logger.error ex.inspect
    logger.error ex.backtrace
    render 'error500', status: 500, formats: [:html]
  end

  protected

  def force_ssl
    if !request.ssl? && (Rails.env.staging? || Rails.env.production?)
      redirect_options = {:protocol => 'https://', :status => :moved_permanently}
      redirect_options.merge!(:params => request.query_parameters)
      redirect_to redirect_options
    end
  end

  private

  def set_locale
    if request.subdomain == "ja" || request.subdomain == "en"
      I18n.locale = request.subdomain
    else
      subdomain = (extract_locale_from_accept_language_header == "ja") ? "ja" : "en"
      I18n.locale = subdomain
      url = [subdomain, ".", request.domain]
      redirect_to url_for(request.query_parameters.merge(:host => url.join))
    end
  end

  def extract_locale_from_accept_language_header
    accept_language = request.env['HTTP_ACCEPT_LANGUAGE']
    accept_language && accept_language.scan(/^[a-z]{2}/).first
  end
end
