class ApplicationController < ActionController::Base
  before_action :set_sentry_context

  unless Rails.env.development?
    rescue_from Exception, with: :error500
    rescue_from ActiveRecord::RecordNotFound, ActionController::UnknownFormat, with: :error404
    # UnknownFormat のサブクラスだが、テンプレートの書き忘れなのでエラーとして通知する。
    rescue_from ActionController::MissingExactTemplate, with: :error500
  end

  layout -> { turbo_frame_request? ? 'turbo_rails/frame' : 'common' }
  helper_method :reviewing?

  def error404
    render_error_page 'error404', 404
  end

  private

  def error500(ex)
    Sentry.capture_exception(ex)
    logger.error ex.inspect
    logger.error ex.backtrace
    render_error_page 'error500', 500
  end

  # エラーページは対象のフレームを含まず画面全体に表示されるため、フレーム内のリクエストでもフレーム用のレイアウトを使わない。
  def render_error_page(template, status)
    render template, status: status, formats: [:html], layout: 'common'
  end

  def reviewing?(navigation = params)
    navigation[:review].to_s == 'true'
  end

  def redirect_to_next_review
    if current_user.posts.reviewable.exists?
      redirect_to review_path, status: :see_other
    else
      redirect_to review_path(completed: true), status: :see_other
    end
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
