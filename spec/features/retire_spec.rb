require 'spec_helper'

describe 'ユーザが退会する' do
  context "ログインして退会ページに遷移したとき" do
    let(:user) { user = Fabricate(:user) }

    before do
      sign_in(user.email, user.password)
      visit user_retire_path
    end

    it '"退会"と表示されていること' do
      expect(page).to have_content '退会'
    end

    context "かつパスワード欄に正しいパスワードを入れて'退会する'ボタンを押し、ダイアログでOKを押したとき", js: true do
      before do
        accept_confirm do
          fill_in 'パスワード', with: user.password
          click_button '退会する'
        end
      end

      it '"退会しました"と表示されていること' do
        expect(page).to have_content '退会しました'
      end
    end

    context "かつパスワード欄に不正なパスワードを入れて'退会する'ボタンを押し、ダイアログでOKを押したとき", js: true do
      before do
        accept_confirm do
          fill_in 'パスワード', with: 'hoge'
          click_button '退会する'
        end
      end

      it '"パスワードが間違っています"と表示されていること' do
        expect(page).to have_content 'パスワードが間違っています'
      end
    end
  end
end
