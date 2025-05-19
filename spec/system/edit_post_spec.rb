require 'spec_helper'

describe 'ユーザが自分の投稿を閲覧する', solr: true, js: true do
  context "ログインして一覧ページを表示しているとき" do
    before do
      user = Fabricate(:user)
      [
        ['晴れた', 1.hours.ago, 1.hours.ago],
        ['雨みたい', 2.hours.ago, 2.hours.ago]
      ].each do |(body, created_at, modified_at)|
        Fabricate(:post, user: user, body: body, created_at: created_at, modified_at: modified_at)
      end
      sign_in(user.email, user.password)
      visit posts_path
    end

    it '削除リンクを押して、ダイアログでOKボタンを押すと該当する投稿が消えること' do
      accept_confirm do
        within 'div.post:nth-child(1)' do
          find('[data-behavior=destroy]').click
        end
      end
      expect(page).to have_no_content('晴れた')
    end

    context "一番上の投稿の編集リンクを押したとき" do
      before do
        within 'div.post:nth-child(1)' do
          find('[data-behavior=edit]').click
        end
      end

      it '新しく編集用のフィールドが表示されること' do
        within 'div.post:nth-child(1)' do
          expect(find('[data-behavior=view-element]', visible: false)).not_to be_visible
          expect(find('[data-behavior=edit-element]')).to be_visible
        end
      end

      it 'かつキャンセルボタンを押したときに元に戻ること' do
        within 'div.post:nth-child(1)' do
          find('[data-behavior=cancel]').click
          expect(find('[data-behavior=edit-element]', visible: false)).not_to be_visible
          expect(find('[data-behavior=view-element]')).to be_visible
        end
      end

      it 'かつ編集内容を入力し編集ボタンを押すと編集内容が表示されること' do
        within 'div.post:nth-child(1)' do
          find('[data-behavior=body]').set '晴れると良いな'
          find('[data-behavior=update]').click
          expect(page).to have_content '晴れると良いな'
        end
      end

      it 'かつ編集内容を制限文字以上入力し編集ボタンを押しても、編集内容が保存されていないこと' do
        long_text = 'あ' * (Post::MAX_BODY_LENGTH + 1)
        within 'div.post:nth-child(1)' do
          find('[data-behavior=body]').set long_text
          accept_alert do
            find('[data-behavior=update]').click
          end
          visit current_path
          expect(page).to have_no_content long_text
        end
      end
    end
  end
end
