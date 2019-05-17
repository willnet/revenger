# -*- coding: utf-8 -*-
class RemindersController < ApplicationController
  before_action :authenticate_user!

  def edit
    @user = current_user
  end

  def update
    @user = current_user
    @user.receive_reminder = params[:user][:receive_reminder]
    if @user.save
      flash.now[:notice] = '更新しました'
    end
    render action: :edit
  end
end
