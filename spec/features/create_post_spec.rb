# -*- coding: utf-8 -*-
require 'spec_helper'

describe '登録済みユーザが、自分のメモを保存するために文章を投稿する' do
  context 'ログインして投稿ページに遷移したとき' do
    before do
      user = Fabricate(:user)
      sign_in(user.email, user.password)
      visit new_post_path
    end

    it 'メインビュー中に"新規作成"と表示されていること' do
      within 'legend' do
        expect(page).to have_content '新規作成'
      end
    end

    context '何か適当な文言を入力し、"create!"ボタンを押したとき' do
      before do
        fill_in 'post_body', with: '適当な文言'
        click_button 'create!'
      end

      it '一覧ページに遷移していること' do
        expect(page.current_path).to eq posts_path
      end

      it '正常に投稿できた旨が表示されていること' do
        expect(page).to have_content(I18n.t('posts.created'))
      end
    end

    context '文言を入力せずに"create!"ボタンを押したとき' do
      before { click_button 'create!' }

      it 'エラー文言が表示されていること' do
        expect(page).to have_content(I18n.t('errors.messages.blank'))
      end
    end
  end
end
