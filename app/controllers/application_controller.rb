class ApplicationController < ActionController::Base
  before_action :set_sentry_context

  unless Rails.env.development?
    rescue_from Exception, with: :error500
    rescue_from ActiveRecord::RecordNotFound, with: :error404
  end

  layout 'common'

  def error404
    render 'error404', status: 404, formats: [:html]
  end

  private

  def error500(ex)
    Sentry.capture_exception(ex)
    logger.error ex.inspect
    logger.error ex.backtrace
    render 'error500', status: 500, formats: [:html]
  end

  def after_sign_in_path_for(user)
    review_path
  end

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

  def set_sentry_context
    Sentry.set_user(id: session[:user_id])
    Sentry.set_extras(params: params.to_unsafe_h, url: request.url)
  end
end
