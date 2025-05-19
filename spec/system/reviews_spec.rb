require 'spec_helper'

describe "自分の書いた投稿を復習するために、レビュータブを閲覧する", js: true do
  context "ログインしてレビューページを表示しているとき" do
    before do
      user = Fabricate(:user)
      [
       ['晴れた', 1.hours.ago],
       ['疲れた', 2.hours.ago],
       ['曇り', 1.day.ago]
      ].each do |(body, review_at)|
        Fabricate(:post, user: user, body: body, review_at: review_at)
      end
      sign_in(user.email, user.password)
      visit review_path
    end

    it '"read it!"リンクを押すと、次の復習内容が表示されること', solr: true do
      find('[data-behavior=read]').click
      expect(page).to have_content '疲れた'
    end

    it '編集リンクを押すと新しく編集用のフィールドが表示されること' do
      find('[data-behavior=edit]').click
      expect(find('[data-behavior=view-element]', visible: false)).not_to be_visible
      expect(find('[data-behavior=edit-element]')).to be_visible
    end

    it '編集リンクを押してキャンセルボタンを押すと元に戻ること' do
      find('[data-behavior=edit]').click
      find('[data-behavior=cancel]').click
      expect(find('[data-behavior=edit-element]', visible: false)).not_to be_visible
      expect(find('[data-behavior=view-element]')).to be_visible
    end

    it '削除リンクを押し、ダイアログでOKボタンを押すと次の復習内容が表示されること', solr: true do
      accept_confirm do
        find('[data-behavior=destroy]').click
      end
      expect(page).to have_content '疲れた'
    end

    it '編集リンクを押して、編集内容を入力し編集ボタンを押すと編集内容が表示されること', solr: true do
      find('[data-behavior=edit]').click
      find('[data-behavior=body]').set '晴れると良いな'
      find('[data-behavior=update]').click
      expect(page).to have_content '晴れると良いな'
    end

    it '編集リンクを押して、編集内容を制限文字以上入力し編集ボタンを押しても保存されていないこと', solr: true do
      long_text = 'あ' * (Post::MAX_BODY_LENGTH + 1)
      find('[data-behavior=edit]').click
      find('[data-behavior=body]').set long_text
      accept_alert do
        find('[data-behavior=update]').click
      end
      visit current_path
      expect(page).to have_no_content long_text
    end
  end
end
