class RemindersController < ApplicationController
  before_action :authenticate_user!

  def edit
    @user = current_user
  end

  def update
    @user = current_user
    @user.receive_reminder = params[:user][:receive_reminder]
    if @user.save
      redirect_to edit_reminder_path, notice: '更新しました', status: :see_other
    else
      render :edit, status: :unprocessable_content
    end
  end
end
