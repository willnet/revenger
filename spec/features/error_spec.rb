# -*- coding: utf-8 -*-
require 'spec_helper'

describe "ユーザが不正な操作をしたときにエラーがおこったことを認識できる" do
  context 'でたらめなURLでアクセスしたとき' do
    before { visit '/fdhoaifjewejiaoej' }

    it '404ページが表示されること' do
      expect(page).to have_content 'ご指定になったページは存在しません'
    end
  end
end
