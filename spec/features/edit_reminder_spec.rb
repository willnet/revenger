require 'spec_helper'

describe 'リマインダメールの送信設定をオフにする' do
  context '送信設定がオンのユーザがログインしてメール送信設定ページへ遷移したとき' do
    before do
      user = Fabricate(:user)
      sign_in(user.email, user.password)
      visit edit_reminder_path
    end

    it '"リマインダメール設定"と表示されていること' do
      expect(page).to have_content('リマインダメール設定')
    end

    context 'かつ"送信しない"をチェックして"更新"ボタンをクリックしたとき' do
      before do
        choose '送信しない'
        click_button '更新'
      end

      it '"更新しました"と表示されること' do
        expect(page).to have_content('更新しました')
      end
    end
  end
end
