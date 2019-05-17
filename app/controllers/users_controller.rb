# -*- coding: utf-8 -*-
# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  hatena_key             :string(255)      not null
#  default_duration       :integer          default(1)
#  email                  :string(255)      default(""), not null
#  encrypted_password     :string(255)      default(""), not null
#  confirmation_token     :string(255)
#  confirmed_at           :datetime
#  confirmation_sent_at   :datetime
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0)
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string(255)
#  last_sign_in_ip        :string(255)
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  receive_reminder       :boolean          default(TRUE)
#  unconfirmed_email      :string(255)
#

class UsersController < ApplicationController
  before_action :authenticate_user!

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
