# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  confirmation_sent_at   :datetime
#  confirmation_token     :string
#  confirmed_at           :datetime
#  current_sign_in_at     :datetime
#  current_sign_in_ip     :string
#  default_duration       :integer          default(1)
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  last_sign_in_at        :datetime
#  last_sign_in_ip        :string
#  receive_reminder       :boolean          default(TRUE)
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  sign_in_count          :integer          default(0)
#  unconfirmed_email      :string
#  created_at             :datetime
#  updated_at             :datetime
#

require 'spec_helper'

describe User do
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
