class RegistrationsController < Devise::RegistrationsController
  before_action :validate_cloudflare_turnstile, only: [:create]
  
  rescue_from RailsCloudflareTurnstile::Forbidden do
    flash[:alert] = 'Turnstile検証に失敗しました。もう一度お試しください。'
    redirect_to signup_path
  end

  protected

  def after_update_path_for(user)
    edit_user_path
  end
end
