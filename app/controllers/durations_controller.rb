# -*- coding: utf-8 -*-
class DurationsController < ApplicationController
  before_filter :authenticate_user!

  def edit
    @user = current_user
  end

  def update
    @user = current_user
    @user.default_duration = params[:user][:default_duration]
    if @user.save
      flash.now[:notice] = '更新しました'
    end
    render action: :edit
  end
end
