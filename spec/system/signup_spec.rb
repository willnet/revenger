require 'spec_helper'

describe 'ユーザがrevengerに新規登録する', :js do
  describe 'サインアップページに遷移したとき' do
    before { visit signup_path }

    context "正しい情報を入力し、ユーザ登録ボタンを押したとき" do
      before do
        fill_in "user_email", with: "new_user@example.com"
        fill_in "user_password", with: "password123"
        fill_in "user_password_confirmation", with: "password123"
        check "user_agree"
        click_button 'ユーザ登録'
      end

      it '確認メールが送信される旨が表示され、ユーザが作成されること' do
        expect(page).to have_content('本人確認用のメールが送られました')
        user = User.find_by(email: "new_user@example.com")
        expect(user).to be_present
      end
    end

    context "利用規約に同意せずにユーザ登録ボタンを押したとき" do
      before do
        fill_in "user_email", with: "new_user@example.com"
        fill_in "user_password", with: "password123"
        fill_in "user_password_confirmation", with: "password123"
        # 利用規約のチェックボックスをチェックしない
        click_button 'ユーザ登録'
      end

      it 'ユーザが作成されないこと' do
        expect(page).to have_content('利用規約に同意してください。')
        user = User.find_by(email: "new_user@example.com")
        expect(user).to be_nil
      end
    end
  end
end
