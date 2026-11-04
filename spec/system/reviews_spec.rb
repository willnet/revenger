require 'spec_helper'

describe "自分の書いた投稿を復習するために、レビュータブを閲覧する", js: true do
  context "ログインしてレビューページを表示しているとき" do
    before do
      @user = Fabricate(:user)
      [
       ['晴れた', 1.hours.ago],
       ['疲れた', 2.hours.ago],
       ['曇り', 1.day.ago]
      ].each do |(body, review_at)|
        Fabricate(:post, user: @user, body: body, review_at: review_at)
      end
      sign_in(@user.email, @user.password)
      visit review_path
    end

    it '"read it!"ボタンを押すと、次の復習内容と残件数が表示されること' do
      expect(page).to have_title 'レビュー (3) - revenger'
      find('[data-behavior=read]').click
      expect(page).to have_content '疲れた'
      expect(page).to have_css('[data-behavior=count]', text: '2')
      expect(page).to have_title 'レビュー (2) - revenger'
      expect(page).to have_current_path review_path
    end

    it '編集リンクを押すと新しく編集用のフィールドが表示されること' do
      find('[data-behavior=edit]').click
      expect(page).to have_no_css('[data-behavior=view-element]')
      expect(page).to have_no_css('[data-behavior=read]')
      expect(find('[data-behavior=edit-element]')).to be_visible
    end

    it '編集リンクを押してキャンセルボタンを押すと元に戻ること' do
      find('[data-behavior=edit]').click
      find('[data-behavior=cancel]').click
      expect(page).to have_no_css('[data-behavior=edit-element]')
      expect(find('[data-behavior=view-element]')).to be_visible
      expect(page).to have_css('[data-behavior=read]')
    end

    it '削除ボタンを押し、ダイアログでOKボタンを押すと次の復習内容が表示されること' do
      accept_confirm do
        find('[data-behavior=destroy]').click
      end
      expect(page).to have_content '疲れた'
      expect(page).to have_css('[data-behavior=count]', text: '2')
      expect(page).to have_title 'レビュー (2) - revenger'
      expect(page).to have_current_path review_path
    end

    it '編集して保存すると、同じメモを表示し、残件数を維持すること' do
      find('[data-behavior=edit]').click
      find('[data-behavior=body]').set '晴れると良いな'
      find('[data-behavior=update]').click
      expect(page).to have_content '晴れると良いな'
      expect(page).to have_css('[data-behavior=count]', text: '3')
      expect(page).to have_css('[data-behavior=read]')
      expect(page).to have_title 'レビュー (3) - revenger'
    end

    it '編集の入力エラーを表示し、修正して保存できること' do
      long_text = 'あ' * (Post::MAX_BODY_LENGTH + 1)
      find('[data-behavior=edit]').click
      find('[data-behavior=body]').set long_text
      find('[data-behavior=update]').click
      expect(page).to have_content "#{Post::MAX_BODY_LENGTH}文字以内"
      expect(find('[data-behavior=body]').value).to eq long_text
      expect(@user.posts.find_by!(body: '曇り').body).to eq '曇り'
      find('[data-behavior=body]').set '修正した本文'
      find('[data-behavior=update]').click
      expect(page).to have_content '修正した本文'
      expect(page).to have_css('[data-behavior=read]')
    end

    it '選択した復習間隔で次回のレビューを予約すること' do
      choose '1 week'
      find('[data-behavior=read]').click
      expect(page).to have_content '疲れた'
      expect(page).to have_checked_field '1 day'
      post = @user.posts.find_by!(body: '曇り')
      expect(post.duration).to eq 7
      expect(post.review_at).to be_within(1.minute).of(7.days.from_now)
    end

    it 'no more を選んで既読にすると復習対象から外れること' do
      choose 'no more'
      find('[data-behavior=read]').click
      expect(page).to have_content '疲れた'
      post = @user.posts.find_by!(body: '曇り')
      expect(post.duration).to be_nil
      expect(post.review_at).to be_nil
    end

    { '1 week' => 7, 'no more' => nil }.each do |label, duration|
      it "#{label} を選んで編集をキャンセルした後も、その間隔で既読にできること" do
        choose label
        find('[data-behavior=edit]').click
        expect(page).to have_checked_field label
        find('[data-behavior=cancel]').click
        expect(page).to have_checked_field label
        find('[data-behavior=read]').click
        expect(page).to have_content '疲れた'

        post = @user.posts.find_by!(body: '曇り')
        expect(post.duration).to eq duration
        if duration
          expect(post.review_at).to be_within(1.minute).of(duration.days.from_now)
        else
          expect(post.review_at).to be_nil
        end
      end
    end

    it '選択した復習間隔を保持して本文を編集・保存できること' do
      choose '1 week'
      find('[data-behavior=edit]').click
      find('[data-behavior=body]').set '復習間隔も保持する'
      find('[data-behavior=update]').click
      expect(page).to have_content '復習間隔も保持する'
      expect(page).to have_checked_field '1 week'
      expect(@user.posts.find_by!(body: '復習間隔も保持する').duration).to eq 7
      find('[data-behavior=read]').click
      expect(page).to have_content '疲れた'
    end

    it '最後のレビューを終えると完了メッセージが表示されること' do
      ['疲れた', '晴れた', '今日のレビューは終了です！お疲れ様でした'].each do |text|
        find('[data-behavior=read]').click
        expect(page).to have_content text
      end
      expect(page).to have_no_css('[data-behavior=read]')
      expect(page).to have_title 'レビュー - revenger', exact: true
      expect(page).to have_current_path review_path(completed: true)
      expect(@user.posts.reviewable).to be_empty
    end

    it '最後の復習ノルマを削除した場合も完了メッセージが表示されること' do
      Fabricate(:post, user: @user, body: 'まだ復習しないメモ', review_at: 1.day.from_now)
      %w[曇り 疲れた 晴れた].each do |body|
        accept_confirm { find('[data-behavior=destroy]').click }
        expect(page).to have_no_content body
      end
      expect(page).to have_content '今日のレビューは終了です！お疲れ様でした'
      expect(page).to have_title 'レビュー - revenger', exact: true
      expect(page).to have_current_path review_path(completed: true)
      expect(@user.posts.reviewable).to be_empty
    end

    it 'メモをすべて削除するとメモ作成の案内が表示されること' do
      %w[曇り 疲れた 晴れた].each do |body|
        accept_confirm { find('[data-behavior=destroy]').click }
        expect(page).to have_no_content body
      end
      expect(page).to have_content 'あなたはメモを一つも作られていないようです'
      expect(page).to have_title 'レビュー - revenger', exact: true
      expect(@user.posts).to be_empty
    end
  end
end
