require 'spec_helper'

describe "ユーザ情報を編集する", js: true  do
  context "ログインしてユーザ情報編集ページに遷移したとき" do
    let(:user) { Fabricate(:user) }

    before do
      sign_in(user.email, user.password)
      visit edit_user_path
    end

    it 'ユーザ情報と表示されていること' do
      expect(page).to have_content 'ユーザ情報'
    end

    context 'かつメールアドレスを変更し、現在のパスワードを正しく入力して"更新"ボタンを押したとき' do
      before do
        page.has_content? 'ユーザ情報'
        fill_in 'メールアドレス', with: 'hoge@fuga.com'
        fill_in '現在のパスワード', with: user.password
        click_button '更新'
      end

      it '"メールアドレス確認用のメールをお送りしました。メール中のリンクをクリックするとメールアドレスの変更が反映されます"と表示されていること' do
        expect(page).to have_content 'メールアドレス確認用のメールをお送りしました。メール中のリンクをクリックするとメールアドレスの変更が反映されます'
      end

      it 'ユーザ情報編集ページにいること' do
        expect(page).to have_current_path(edit_user_path)
      end

      context 'かつ送信されたメールアドレスのURLをクリックしたとき' do
        before do
          page.has_content? 'メールアドレス確認用のメールをお送りしました'
          open_email('hoge@fuga.com')
          current_email.click_link user_confirmation_path
        end

        it '"メールアドレスの確認が完了しました"と表示されていること' do
          expect(page).to have_content('メールアドレスの確認が完了しました')
        end
      end
    end

    context 'かつメールアドレスを変更し、現在のパスワードに不正な文字列を入力して"更新"ボタンを押したとき' do
      before do
        page.has_content? 'ユーザ情報'
        fill_in 'メールアドレス', with: 'hoge@fuga.com'
        fill_in '現在のパスワード', with: 'abcdefg'
      end

      it '"現在のパスワードは不正な値です"と表示されていること' do
        click_button '更新'
        expect(page).to have_content '現在のパスワードは不正な値です'
      end

      it 'メールが送信されていないこと' do
        expect { click_button '更新' }.not_to change { ActionMailer::Base.deliveries.length }
      end
    end

    context 'かつ現在のパスワードと新しいパスワード、パスワード確認を正しく入力して"更新"ボタンを押したとき' do
      before do
        page.has_content? 'ユーザ情報'
        fill_in '現在のパスワード', with: user.password
        fill_in 'user_password', with: 'hogehoge'
        fill_in 'user_password_confirmation', with: 'hogehoge'
        click_button '更新'
      end

      it '"アカウント情報を変更しました"と表示されていること' do
        expect(page).to have_content 'アカウント情報を変更しました'
      end
    end

    context 'かつ現在のパスワードを正しく入力せずに新しいパスワード、パスワード確認を入力して"更新"ボタンを押したとき' do
      before do
        page.has_content? 'ユーザ情報'
        fill_in '現在のパスワード', with: 'abcdefg'
        fill_in 'user_password', with: 'hogehoge'
        fill_in 'user_password_confirmation', with: 'hogehoge'
        click_button '更新'
      end

      it '"アカウント情報を変更しました"と表示されていないこと' do
        expect(page).not_to have_content 'アカウント情報を変更しました'
      end
    end
  end
end
