require 'spec_helper'

describe 'ユーザが revenger の機能を使うためにログインをする' do
  let!(:user) { Fabricate(:user) }

  describe 'ログインページに遷移したとき' do
    before { visit login_path }
    context "かつ正しいメールアドレスとパスワードを入力し、ログインボタンを押したとき" do
      before do
        fill_in "user_email", with: user.email
        fill_in "user_password", with: user.password
        click_button I18n.t("misc.sign_in")
      end

      it 'ログインした旨が表示されること' do
        expect(page).to have_content(I18n.t("devise.sessions.signed_in"))
      end

      it 'レビューページに遷移していること' do
        expect(page).to have_current_path(review_path)
      end
    end

    context "不正なメールアドレスと正しいパスワードを入力し、ログインボタンを押したとき" do
      before do
        fill_in "user_email", with: user.email + 'hoge'
        fill_in "user_password", with: user.password
        click_button I18n.t("misc.sign_in")
      end

      it 'ログインできない旨が表示されること' do
        expect(page).to have_no_content(I18n.t("devise.sessions.signed_in"))
      end

      it 'ログインページにいること' do
        expect(page).to have_current_path(login_path)
      end
    end

    context "正しいメールアドレスと不正なパスワードを入力したとき" do
      before do
        fill_in "user_email", with: user.email
        fill_in "user_password", with: user.password + 'hoge'
        click_button I18n.t("misc.sign_in")
      end

      it 'ログインできない旨が表示されること' do
        expect(page).to have_no_content(I18n.t("devise.sessions.signed_in"))
      end

      it 'ログインページにいること' do
        expect(page).to have_current_path(login_path)
      end
    end
  end
end
