# -*- coding: utf-8 -*-
require 'spec_helper'

describe 'ノーマルビューを表示している' do
  before do
    user = Fabricate(:user)
    [
      ['ふが5-1', 5.hours.ago, 1.hours.ago],
      ['ほげ3-2', 3.hours.ago, 2.hours.ago],
      ['ふが4-3', 4.hours.ago, 3.hours.ago],
      ['ふが24-24', 1.day.ago, 1.day.ago]
    ].each do |(body, created_at, modified_at)|
      Fabricate(:post, user: user, body: body, created_at: created_at, modified_at: modified_at)
    end
    sign_in(user.email, 'password')
    visit posts_path
  end

  context '検索したとき' do
    before do
      fill_in 'search', with: 'ふが'
      find('[data-behavior=search]').click
    end

    it '作成日降順で検索結果が表示されること' do
      expect(page).to have_bodies ['4-3', '5-1', '24-24']
    end

    context "さらに'作成日時'をクリックしたとき" do
      before { click_link "作成日時" }

      it '作成日昇順で検索結果が表示されること' do
        expect(page).to have_bodies ['24-24', '5-1', '4-3']
      end

      context "さらに'作成日時'をクリックしたとき" do
        before { click_link "作成日時" }

        it '作成日降順で検索結果が表示されること' do
          expect(page).to have_bodies ['4-3', '5-1', '24-24']
        end
      end
    end
    context "'更新日時'をクリックしたとき" do
      before { click_link "更新日時" }

      it '更新日昇順で検索結果が表示されること' do
        expect(page).to have_bodies ['24-24', '4-3', '5-1']
      end

      context "さらに'更新日時'をクリックしたとき" do
        before { click_link "更新日時" }

        it '更新日降順で検索結果が表示されること' do
          expect(page).to have_bodies ['5-1', '4-3', '24-24']
        end
      end
    end
  end

  context "'作成日時'をクリックしたとき" do
    before { click_link "作成日時" }

    it '作成日昇順で投稿が表示されること' do
      expect(page).to have_bodies ['24-24', '5-1', '4-3', '3-2']
    end

    context "さらに'作成日時'をクリックしたとき" do
      before { click_link "作成日時" }

      it '作成日降順で投稿が表示されること' do
        expect(page).to have_bodies ['3-2', '4-3', '5-1', '24-24']
      end

      context "さらに'作成日時'をクリックしたとき" do
        before { click_link "作成日時" }

        it '作成日昇順で投稿が表示されること' do
          expect(page).to have_bodies ['24-24', '5-1', '4-3', '3-2']
        end
      end
    end
  end

  context "'更新日時'をクリックしたとき" do
    before { click_link "更新日時" }

    it '更新日昇順になること' do
      expect(page).to have_bodies ['24-24', '4-3', '3-2', '5-1']
    end

    context "さらに'更新日時'をクリックしたとき" do
      before { click_link "更新日時" }

      it '更新日降順になること' do
        expect(page).to have_bodies ['5-1', '3-2', '4-3', '24-24']
      end

      context "さらに'更新日時'をクリックしたとき" do
        before { click_link "更新日時" }

        it '更新日昇順になること' do
          expect(page).to have_bodies ['24-24', '4-3', '3-2', '5-1']
        end
      end
    end
  end
end
