# -*- coding: utf-8 -*-
require 'spec_helper'

describe 'デフォルトの復習間隔を変更する' do
  context 'ユーザがログインしてデフォルト復習間隔設定ページへ遷移したとき' do
    before do
      user = Fabricate(:user)
      sign_in(user.email, user.password)
      visit edit_duration_path
    end

    it '"デフォルト復習間隔"と表示されていること' do
      expect(page).to have_content('デフォルト復習間隔')
    end

    context 'かつ"7"を選択して"更新"ボタンをクリックしたとき' do
      before do
        select '7', from: 'user_default_duration'
        click_button '更新'
      end

      it '"更新しました"と表示されること' do
        expect(page).to have_content('更新しました')
      end
    end
  end
end
