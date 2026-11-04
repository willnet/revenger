require 'spec_helper'

describe 'メモの表示と編集' do
  let(:user) { Fabricate(:user) }
  let!(:note) { Fabricate(:post, user: user, body: '# 自分のメモ') }

  before do
    post login_path, params: { user: { email: user.email, password: user.password } }
  end

  it 'JavaScript による追加取得なしで一覧の本文を表示すること' do
    other_note = Fabricate(:post, body: '別のユーザのメモ')
    get posts_path

    expect(response).to have_http_status(:ok)
    expect(response.body).to include '<h1>自分のメモ</h1>'
    expect(response.body).not_to include other_note.body
  end

  it '本文に HTML を含む場合も編集フォームの値として扱うこと' do
    body = '</textarea><script>alert("本文")</script> & "引用"'
    note.update!(body: body)

    get edit_post_path(note), headers: { 'Turbo-Frame' => "post_#{note.id}" }

    document = Nokogiri::HTML5(response.body)
    expect(document.at_css('textarea').text).to eq body
    expect(document.css('script')).to be_empty
    expect(document.at_css("turbo-frame#post_#{note.id}")).to be_present
  end

  it '入力が空なら 422 と編集フォームを返し、保存済みの本文を維持すること' do
    patch post_path(note), params: { post: { body: '' } }, headers: {
      'Turbo-Frame' => "post_#{note.id}",
      'Accept' => 'text/vnd.turbo-stream.html, text/html'
    }

    expect(response).to have_http_status(422)
    expect(response.media_type).to eq 'text/html'
    expect(response.body).to include I18n.t('errors.messages.blank')
    expect(note.reload.body).to eq '# 自分のメモ'
  end

  it 'セッションが切れたフレームリクエストでは画面全体をログイン画面に切り替えること' do
    get logout_path
    get edit_post_path(note), headers: { 'Turbo-Frame' => "post_#{note.id}" }
    expect(response).to redirect_to new_user_session_path

    follow_redirect! headers: { 'Turbo-Frame' => "post_#{note.id}" }
    document = Nokogiri::HTML5(response.body)
    expect(document.at_css('meta[name="turbo-visit-control"]')['content']).to eq 'reload'
  end

  context '別のユーザのメモを指定したとき' do
    let(:other_note) { Fabricate(:post, body: '別のユーザのメモ') }

    it '表示や編集ができないこと' do
      get post_path(other_note)
      expect(response).to have_http_status(:not_found)
      expect(response.body).not_to include other_note.body

      get edit_post_path(other_note), headers: { 'Turbo-Frame' => "post_#{other_note.id}" }
      expect(response).to have_http_status(:not_found)
      expect(response.body).not_to include other_note.body
    end

    it '更新や削除ができないこと' do
      patch post_path(other_note), params: { post: { body: '変更' } }
      expect(response).to have_http_status(:not_found)
      expect(other_note.reload.body).to eq '別のユーザのメモ'

      delete post_path(other_note)
      expect(response).to have_http_status(:not_found)
      expect(Post.exists?(other_note.id)).to be true
    end
  end
end
