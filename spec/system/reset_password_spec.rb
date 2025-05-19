require 'spec_helper'

describe 'パスワードを忘れたユーザがパスワードを再設定する' do
  context 'トップページから、"ログイン"をクリックし、さらに"パスワードを忘れた場合"をクリックしたとき' do
    before do
      visit root_path
      click_link 'ログイン'
      click_link 'パスワードを忘れた場合'
    end

    it '"パスワードを忘れた場合"と表示されていること' do
      expect(page.text).to be_include 'パスワードを忘れた場合'
    end

    context 'かつ、DBに存在するメールアドレスを入力して"送信"ボタンを押したとき' do
      before do
        Fabricate(:user, email: 'hoge@fuga.com')
        fill_in 'user_email', with: 'hoge@fuga.com'
        click_button '送信'
      end

      it '"パスワードのリセット方法が書かれたメールを送信します。しばらくお待ちください。"と表示されていること' do
        expect(page.find('#flash')).to have_text 'パスワードのリセット方法が書かれたメールを送信します。しばらくお待ちください。'
      end

      it '"エラー"と表示されていないこと' do
        expect(page).to have_no_text 'エラー'
      end

      context 'かつ送信されたメールアドレスのURLをクリックしたとき' do
        before do
          open_email('hoge@fuga.com')
          current_email.click_link edit_user_password_path
        end

        it '"パスワードの更新"と表示されていること' do
          expect(page).to have_content('パスワードの更新')
        end

        context 'かつ新しいパスワードを入力し、"パスワードの更新"をクリックしたとき' do
          before do
            fill_in 'user_password', with: 'newpassword'
            fill_in 'user_password_confirmation', with: 'newpassword'
            click_button 'パスワードの更新'
          end

          it '"パスワードを変更しました。"と表示されていること' do
            expect(page).to have_content('パスワードを変更しました。')
          end
        end
      end
    end
  end
end
