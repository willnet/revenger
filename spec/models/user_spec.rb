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
#

require 'spec_helper'

describe User do
  describe 'before_create :set_hatena_key' do
    context "新しく User が作成されたとき" do
      it '#hatena_key に文字列が設定されていること' do
        user = User.create(email: 'netwillnet@gmail.com', password: 'password')
        expect(user.hatena_key).not_to be_empty
      end
    end
  end

  describe 'before_create :build_initial_posts' do
    context "新しく User が作成されたとき" do
      it '#posts に二件データが作成されていること' do
        user = User.create(email: 'netwillnet@gmail.com', password: 'password')
        expect(user.posts.length).to eq 2
      end
    end
  end

  describe "#destroy" do
    before do
      @user = Fabricate(:user)
      3.times { Fabricate(:post, user: @user) }
    end

    it 'これまでの投稿も全て削除されていること' do
      expect { @user.destroy }.to change { @user.posts.length }.from(3).to(0)
    end
  end
end
