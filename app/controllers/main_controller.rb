class MainController < ApplicationController

  def index
    if user_signed_in?
      redirect_to review_path
      return
    end
    @user = User.new
    render layout: 'application'
  end

  def help; end
  def privacy; end
  def terms; end
end
