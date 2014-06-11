# -*- coding: utf-8 -*-
class UsersController < ApplicationController
  before_filter :authenticate_user!

  def retire; end

  def destroy
    unless current_user.valid_password? params[:password]
      flash.now[:alert] = 'パスワードが間違っています'
      render 'retire'
      return
    end
    current_user.destroy
    sign_out
    redirect_to root_path, notice: '退会しました'
  end
end
