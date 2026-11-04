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

  it 'フレーム内で存在しないメモを要求されたら画面全体用のエラーページを返すこと' do
    note.destroy!
    get edit_post_path(note), headers: { 'Turbo-Frame' => "post_#{note.id}" }

    expect(response).to have_http_status(:not_found)
    document = Nokogiri::HTML5(response.body)
    expect(document.at_css('.navbar')).to be_present
    expect(document.at_css('link[rel="stylesheet"]')).to be_present
  end

  it 'ページが範囲外なら一覧の条件を保ったまま最後のページへリダイレクトすること' do
    get posts_path(page: 99, search: '自分', created_at: 'asc', review: 'true')

    expect(response).to have_http_status(:see_other)
    expect(response).to redirect_to posts_path(page: 1, search: '自分', created_at: 'asc')
  end

  it 'JSON 形式を要求されたら 404 を返し、エラーとして通知しないこと' do
    expect(Sentry).not_to receive(:capture_exception)

    get posts_path(format: :json)

    expect(response).to have_http_status(:not_found)
  end

  describe '一覧からの削除' do
    let(:turbo_stream_headers) { { 'Accept' => 'text/vnd.turbo-stream.html, text/html' } }

    before do
      user.posts.destroy_all
      12.times do |i|
        Fabricate(:post, user: user, body: "メモ#{i}", created_at: i.hours.ago, modified_at: i.hours.ago)
      end
    end

    def appended_post_ids(body)
      Nokogiri::HTML5(body).css('turbo-stream[action="append"] template').flat_map do |template|
        Nokogiri::HTML5.fragment(template.inner_html).css('turbo-frame').map { |frame| frame['id'] }
      end
    end

    it 'ページ送りのリンクに一覧の条件だけを引き継ぐこと' do
      visible_posts = user.posts.order(created_at: :desc).first(10)

      delete post_path(visible_posts.first, search: 'メモ'), params: { visible_post_ids: visible_posts.map(&:id), extra: 'x' }, headers: turbo_stream_headers

      document = Nokogiri::HTML5(response.body)
      page_links = document.css('turbo-stream[target="posts_pagination_top"] template').flat_map do |template|
        Nokogiri::HTML5.fragment(template.inner_html).css('a').map { |link| link['href'] }
      end
      expect(page_links).to include posts_path(page: 2, search: 'メモ')
      expect(page_links).to all(start_with('/posts?'))
      expect(page_links.join).not_to include('extra', 'visible_post_ids')
    end

    it '表示中のメモとページの内容がずれていても、そのページのメモを取りこぼさずに補充すること' do
      visible_posts = user.posts.order(:modified_at).first(10)
      edited_post, deleted_post = visible_posts.first(2)
      edited_post.update!(modified_at: Time.zone.now)

      delete post_path(deleted_post, modified_at: 'asc'), params: { visible_post_ids: visible_posts.map(&:id) }, headers: turbo_stream_headers

      expect(response).to have_http_status(:ok)
      expect(appended_post_ids(response.body)).to eq(%w[メモ1 メモ0].map { |body| "post_#{user.posts.find_by!(body: body).id}" })
    end
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
