class DurationsController < ApplicationController
  before_action :authenticate_user!

  def edit
    @user = current_user
  end

  def update
    @user = current_user
    @user.default_duration = params[:user][:default_duration]
    if @user.save
      redirect_to edit_duration_path, notice: '更新しました', status: :see_other
    else
      render :edit, status: :unprocessable_content
    end
  end
end
