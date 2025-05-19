require 'spec_helper'

describe 'ユーザが revenger の機能の使用を中止するためにログアウトをする' do

  describe 'ログインしているとき' do
    let!(:user) { Fabricate(:user) }
    before { sign_in(user.email, user.password) }

    it 'かつ、ログアウトページに遷移したとき、ログアウトしていること' do
      visit logout_path
      expect(page).to have_content(I18n.t("devise.sessions.signed_out"))
    end
  end
end
