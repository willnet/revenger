require 'spec_helper'

describe 'ユーザが自分の投稿を閲覧する', js: true do
  context "ログインして一覧ページを表示しているとき" do
    before do
      @user = Fabricate(:user)
      [
        ['晴れた', 1.hours.ago, 1.hours.ago],
        ['雨みたい', 2.hours.ago, 2.hours.ago]
      ].each do |(body, created_at, modified_at)|
        Fabricate(:post, user: @user, body: body, created_at: created_at, modified_at: modified_at)
      end
      sign_in(@user.email, @user.password)
      visit posts_path
      expect(page).to have_css('#posts .post', count: 2)
    end

    it '削除リンクを押して、ダイアログでOKボタンを押すと該当する投稿が消えること' do
      accept_confirm do
        within first('turbo-frame[id^="post_"]') do
          find('[data-behavior=destroy]').click
        end
      end
      expect(page).to have_no_content('晴れた')
    end

    it '削除をキャンセルするとメモが残ること' do
      dismiss_confirm { first('[data-behavior=destroy]').click }
      expect(page).to have_content '晴れた'
      expect(@user.posts.count).to eq 2
    end

    it '別のメモを削除しても未保存の本文と復習間隔を保持すること' do
      within first('turbo-frame[id^="post_"]') do
        find('[data-behavior=edit]').click
        find('[data-behavior=body]').set '未保存の追記'
        choose '1 week'
      end
      accept_confirm do
        within all('turbo-frame[id^="post_"]').last do
          find('[data-behavior=destroy]').click
        end
      end
      expect(page).to have_no_content '雨みたい'
      within first('turbo-frame[id^="post_"]') do
        expect(find('[data-behavior=body]').value).to eq '未保存の追記'
        expect(page).to have_checked_field '1 week'
        find('[data-behavior=update]').click
        expect(page).to have_content '未保存の追記'
      end
      expect(@user.posts.find_by!(body: '未保存の追記').duration).to eq 7
    end

    it 'メモをすべて削除すると空の一覧の案内を表示すること' do
      %w[晴れた 雨みたい].each do |body|
        accept_confirm { first('[data-behavior=destroy]').click }
        expect(page).to have_no_content body
      end
      expect(page).to have_content '投稿がありません'
      expect(page).to have_no_css('.post')
    end

    it '編集しようとしたメモが削除済みならエラーページを画面全体に表示すること' do
      @user.posts.find_by!(body: '晴れた').destroy!
      within first('turbo-frame[id^="post_"]') do
        find('[data-behavior=edit]').click
      end
      expect(page).to have_content 'ご指定になったページは存在しません'
      expect(page).to have_no_css('turbo-frame[id^="post_"]')
      expect(page).to have_css('.navbar')
    end

    it '本文内のリンクから画面全体を遷移できること' do
      @user.posts.first.update!(body: '[書き方を確認](http://www.example.com/help)')
      visit posts_path
      click_link '書き方を確認'
      expect(page).to have_current_path help_path
      expect(page).to have_css('body.main_controller.help_action')
    end

    context '編集画面を画面全体で開いたとき' do
      let(:note) { @user.posts.find_by!(body: '晴れた') }

      before do
        visit edit_post_path(note)
      end

      it '保存するとメモの画面に遷移すること' do
        find('[data-behavior=body]').set '画面全体で編集した'
        find('[data-behavior=update]').click
        expect(page).to have_current_path post_path(note)
        expect(page).to have_title 'メモ - revenger'
        expect(page).to have_content '画面全体で編集した'
      end

      it 'キャンセルするとメモの画面に遷移すること' do
        find('[data-behavior=cancel]').click
        expect(page).to have_current_path post_path(note)
        expect(page).to have_title 'メモ - revenger'
        expect(page).to have_css('[data-behavior=view-element]')
      end
    end

    context "一番上の投稿の編集リンクを押したとき" do
      before do
        within first('turbo-frame[id^="post_"]') do
          find('[data-behavior=edit]').click
        end
      end

      it '新しく編集用のフィールドが表示されること' do
        within first('turbo-frame[id^="post_"]') do
          expect(page).to have_no_css('[data-behavior=view-element]')
          expect(find('[data-behavior=edit-element]')).to be_visible
        end
      end

      it 'かつキャンセルボタンを押したときに元に戻ること' do
        within first('turbo-frame[id^="post_"]') do
          find('[data-behavior=body]').set 'キャンセルする変更'
          find('[data-behavior=cancel]').click
          expect(page).to have_no_css('[data-behavior=edit-element]')
          expect(find('[data-behavior=view-element]')).to be_visible
          expect(page).to have_content '晴れた'
          expect(page).to have_no_content 'キャンセルする変更'
        end
      end

      it 'かつ編集内容を入力し編集ボタンを押すと編集内容が表示されること' do
        within first('turbo-frame[id^="post_"]') do
          find('[data-behavior=body]').set '晴れると良いな'
          find('[data-behavior=update]').click
          expect(page).to have_content '晴れると良いな'
        end
      end

      it '入力エラーを表示して編集内容を保持し、修正して保存できること' do
        long_text = 'あ' * (Post::MAX_BODY_LENGTH + 1)
        within first('turbo-frame[id^="post_"]') do
          find('[data-behavior=body]').set long_text
          find('[data-behavior=update]').click
          expect(page).to have_content "#{Post::MAX_BODY_LENGTH}文字以内"
          expect(find('[data-behavior=body]').value).to eq long_text
          expect(@user.posts.order(:created_at).last.body).to eq '晴れた'
          find('[data-behavior=body]').set '修正した本文'
          find('[data-behavior=update]').click
          expect(page).to have_content '修正した本文'
        end
      end

      it '復習間隔を変更して保存できること' do
        within first('turbo-frame[id^="post_"]') do
          choose '1 week'
          find('[data-behavior=update]').click
          expect(page).to have_css('[data-behavior=view-element]')
          find('[data-behavior=edit]').click
          expect(page).to have_checked_field '1 week'
        end
        expect(@user.posts.find_by!(body: '晴れた').duration).to eq 7
      end

      it 'ほかのメモを編集中でも未保存の内容を維持すること' do
        first('[data-behavior=body]').set 'まだ保存していない内容'
        all('[data-behavior=edit]').last.click
        within all('turbo-frame[id^="post_"]').last do
          find('[data-behavior=body]').set 'もう一つのメモを更新'
          find('[data-behavior=update]').click
          expect(page).to have_content 'もう一つのメモを更新'
        end
        expect(first('[data-behavior=body]').value).to eq 'まだ保存していない内容'
        expect(@user.posts.find_by!(body: '晴れた').body).to eq '晴れた'
      end

      it 'no more を選んで編集を保存できること' do
        within first('turbo-frame[id^="post_"]') do
          choose 'no more'
          find('[data-behavior=update]').click
          expect(page).to have_css('[data-behavior=view-element]')
          find('[data-behavior=edit]').click
          expect(page).to have_checked_field 'no more'
        end
        expect(@user.posts.find_by!(body: '晴れた').duration).to be_nil
      end
    end
  end
end
