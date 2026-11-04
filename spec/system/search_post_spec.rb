require 'spec_helper'

describe 'ノーマルビューを表示している' do
  let(:user) { Fabricate(:user) }

  before do
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

  it '検索に一致するメモがない場合は空の一覧を表示すること' do
    fill_in 'search', with: '一致しない本文'
    find('[data-behavior=search]').click
    expect(page).to have_content '投稿がありません'
    expect(page).to have_no_css('.post')
  end

  it '編集した後に削除しても検索条件と並び順を維持すること' do
    fill_in 'search', with: 'ふが'
    find('[data-behavior=search]').click
    click_link '更新日時'
    within first('turbo-frame[id^="post_"]') do
      find('[data-behavior=edit]').click
      find('[data-behavior=body]').set 'ふが更新'
      find('[data-behavior=update]').click
      expect(page).to have_content 'ふが更新'
      accept_confirm { find('[data-behavior=destroy]').click }
    end
    expect(page).to have_field 'search', with: 'ふが'
    expect(page).to have_bodies ['4-3', '5-1']
    expect(page).to have_link '更新日時▲'
  end

  it '最後のページのメモを削除すると前のページを表示すること' do
    7.times do |i|
      Fabricate(:post, user: user, body: "追加メモ#{i}", created_at: (i + 2).days.ago)
    end
    visit posts_path
    expect(page).to have_css('.post', count: 10)
    within first('.pagination') do
      click_link '次'
    end
    expect(page).to have_css('.post', count: 1)
    expect(page).to have_content '追加メモ6'
    accept_confirm { find('[data-behavior=destroy]').click }
    expect(page).to have_no_content '追加メモ6'
    expect(page).to have_css('.post', count: 10)
    expect(page).to have_field 'search'
  end

  it '削除後に次ページのメモを補充しても編集中の本文を保持し、ページ送りできること' do
    10.times do |i|
      Fabricate(:post, user: user, body: "追加メモ#{i}", created_at: (i + 2).days.ago)
    end
    visit posts_path
    within first('turbo-frame[id^="post_"]') do
      find('[data-behavior=edit]').click
      find('[data-behavior=body]').set '保存前の本文'
    end
    accept_confirm { all('[data-behavior=destroy]').last.click }

    expect(page).to have_css('.post', count: 10)
    expect(page).to have_content '追加メモ6'
    within first('turbo-frame[id^="post_"]') do
      expect(find('[data-behavior=body]').value).to eq '保存前の本文'
      find('[data-behavior=cancel]').click
    end
    within first('.pagination') do
      click_link '次'
    end
    expect(page).to have_current_path posts_path(page: 2)
    expect(page).to have_css('.post', count: 3)
    expect(page).to have_content '追加メモ7'
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
