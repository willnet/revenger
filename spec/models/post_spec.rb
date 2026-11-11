# == Schema Information
#
# Table name: posts
#
#  id          :integer          not null, primary key
#  body        :text
#  duration    :integer          default(1)
#  modified_at :datetime         not null
#  review_at   :datetime
#  created_at  :datetime
#  updated_at  :datetime
#  user_id     :integer          not null
#
# Indexes
#
#  index_posts_on_user_id_and_created_at   (user_id,created_at)
#  index_posts_on_user_id_and_modified_at  (user_id,modified_at)
#  index_posts_on_user_id_and_review_at    (user_id,review_at)
#

require 'spec_helper'

describe Post do

  describe '#body' do
    subject { Fabricate.build(:post) }

    it { is_expected.to accept_values_for(:body, 'あ', "hoge", "!!!!!!", 'ほげほげ') }

    it '3999文字と4000文字の本文を受け付けること' do
      is_expected.to accept_values_for(:body, 'あ' * 3999, 'あ' * 4000)
    end

    it '空文字列や4001文字の本文を受け付けないこと' do
      is_expected.not_to accept_values_for(:body, "", 'あ' * 4001)
    end
  end

  describe '.reviewable' do
    it '現在時刻より前に復習予定のある投稿だけを返すこと' do
      Timecop.freeze(Time.zone.local(2026, 11, 6, 12))
      user = Fabricate(:user)
      overdue_post = Fabricate(:post, user: user, review_at: 1.second.ago)
      Fabricate(:post, user: user, review_at: Time.zone.now)
      Fabricate(:post, user: user, review_at: 1.second.from_now)
      Fabricate(:post, user: user, review_at: nil)

      expect(Post.reviewable).to contain_exactly(overdue_post)
    end
  end

  describe '#refresh_review_at' do
    before { Timecop.freeze(Time.zone.local(2026, 11, 6, 12)) }

    it '復習間隔が1日なら翌日の同時刻に復習を予約すること' do
      post = Fabricate.build(:post, duration: 1, review_at: nil)

      post.refresh_review_at

      expect(post.review_at).to eq 1.day.from_now
    end

    it '復習間隔が未設定なら既存の復習予定を解除すること' do
      post = Fabricate.build(:post, duration: nil, review_at: 1.day.ago)

      post.refresh_review_at

      expect(post.review_at).to be_nil
    end
  end

  context ".search_by_like" do
    before do
      @user = Fabricate(:user)
      [
       ['ふが5-1', 5.hours.ago, 1.hours.ago],
       ['ほげ3-2', 3.hours.ago, 2.hours.ago],
       ['ふが4-3', 4.hours.ago, 3.hours.ago],
       ['ふが24-24', 1.day.ago, 1.day.ago]
      ].each do |(body, created_at, modified_at)|
        Fabricate(:post, user: @user, body: body, created_at: created_at, modified_at: modified_at)
      end
    end

    context "user, {}" do
      subject { Post.search_by_like(@user, {}).map(&:body) }
      it '作成日降順でオブジェクトの配列が返ること' do
        is_expected.to eq ['ほげ3-2', 'ふが4-3', 'ふが5-1', 'ふが24-24']
      end
    end

    context "user, {created_at: 'asc'}" do
      subject { Post.search_by_like(@user, {created_at: 'asc'}).map(&:body) }
      it '作成日昇順でオブジェクトの配列が返ること' do
        is_expected.to eq ['ふが24-24', 'ふが5-1', 'ふが4-3', 'ほげ3-2']
      end
    end

    context "user, {search: '', created_at: 'asc'}" do
      subject { Post.search_by_like(@user, {search: '', created_at: 'asc'}).map(&:body) }
      it '作成日昇順でオブジェクトの配列が返ること' do
        is_expected.to eq ['ふが24-24', 'ふが5-1', 'ふが4-3', 'ほげ3-2']
      end
    end

    context "user, {search: '', created_at: 'desc'}" do
      subject { Post.search_by_like(@user, {search: '', created_at: 'desc'}).map(&:body) }
      it '作成日降順でオブジェクトの配列が返ること' do
        is_expected.to eq ['ほげ3-2', 'ふが4-3', 'ふが5-1', 'ふが24-24']
      end
    end

    context "user, {search: '', created_at: 'asc'}" do
      subject { Post.search_by_like(@user, {search: '', created_at: 'desc'}).map(&:body) }
      it '作成日降順でオブジェクトの配列が返ること' do
        is_expected.to eq ['ほげ3-2', 'ふが4-3', 'ふが5-1', 'ふが24-24']
      end
    end

    context "user, {modified_at: 'asc'}" do
      subject { Post.search_by_like(@user, {modified_at: 'asc'}).map(&:body) }
      it '更新日昇順でオブジェクトの配列が返ること' do
        is_expected.to eq ['ふが24-24', 'ふが4-3', 'ほげ3-2', 'ふが5-1']
      end
    end

    context "user, {search: '', modified_at: 'asc'}" do
      subject { Post.search_by_like(@user, {search: '', modified_at: 'asc'}).map(&:body) }
      it '更新日昇順でオブジェクトの配列が返ること' do
        is_expected.to eq ['ふが24-24', 'ふが4-3', 'ほげ3-2', 'ふが5-1']
      end
    end

    context "user, {modified_at: 'desc'}" do
      subject { Post.search_by_like(@user, {modified_at: 'desc'}).map(&:body) }
      it '更新日降順でオブジェクトの配列が返ること' do
        is_expected.to eq ['ふが5-1', 'ほげ3-2', 'ふが4-3', 'ふが24-24']
      end
    end

    context "user, {search: '', modified_at: 'desc'}" do
      subject { Post.search_by_like(@user, {search: '', modified_at: 'desc'}).map(&:body) }
      it '更新日昇順でオブジェクトの配列が返ること' do
        is_expected.to eq ['ふが5-1', 'ほげ3-2', 'ふが4-3', 'ふが24-24']
      end
    end

    context "{search: 'ふが'}" do
      subject { Post.search_by_like(@user, {search: 'ふが'}).map(&:body) }
      it '"ふが"を含むオブジェクトの配列が作成日降順で返ること' do
        is_expected.to eq ['ふが4-3', 'ふが5-1', 'ふが24-24']
      end
    end

    context "{search: 'ふが', created_at: 'asc'}" do
      subject { Post.search_by_like(@user, {search: 'ふが', created_at: 'asc'}).map(&:body) }
      it '"ふが"を含むオブジェクトの配列が作成日昇順で返ること' do
        is_expected.to eq ['ふが24-24', 'ふが5-1', 'ふが4-3']
      end
    end

    context "{search: 'ふが', created_at: 'desc'}" do
      subject { Post.search_by_like(@user, {search: 'ふが', created_at: 'desc'}).map(&:body) }
      it '"ふが"を含むオブジェクトの配列が作成日降順で返ること' do
        is_expected.to eq ['ふが4-3', 'ふが5-1', 'ふが24-24']
      end
    end

    context "{search: 'ふが', modified_at: 'asc'}" do
      subject { Post.search_by_like(@user, {search: 'ふが', modified_at: 'asc'}).map(&:body) }
      it '"ふが"を含むオブジェクトの配列が更新日昇順で返ること' do
        is_expected.to eq ['ふが24-24', 'ふが4-3', 'ふが5-1']
      end
    end

    context "{search: 'ふが', modified_at: 'desc'}" do
      subject { Post.search_by_like(@user, {search: 'ふが', modified_at: 'desc'}).map(&:body) }
      it '"ふが"を含むオブジェクトの配列が更新日降順で返ること' do
        is_expected.to eq ['ふが5-1', 'ふが4-3', 'ふが24-24']
      end
    end

    context 'アルファベットで検索するとき' do
      before do
        %w[before-rails-after before-RAILS-after before-Rails-after before-ruby-after].each do |body|
          Fabricate(:post, user: @user, body: body)
        end
      end

      %w[rails RAILS Rails].each do |query|
        it "#{query} を含む投稿が大文字・小文字を区別せず返ること" do
          posts = Post.search_by_like(@user, {search: query})

          expect(posts.map(&:body)).to match_array %w[before-rails-after before-RAILS-after before-Rails-after]
        end
      end
    end
  end

  describe '.search_by_like のページング' do
    before { Timecop.freeze(Time.zone.local(2026, 11, 6, 12)) }

    let(:user) { Fabricate(:user) }
    let!(:posts) do
      Array.new(11) do |i|
        Fabricate(:post, user: user, body: "ページ境界#{i}", modified_at: (11 - i).minutes.ago)
      end
    end

    before do
      Fabricate(:post, body: 'ページ境界の他人の投稿', modified_at: Time.zone.now)
    end

    [nil, 'ページ境界'].each do |query|
      context(query ? '検索するとき' : '検索しないとき') do
        it '更新日時降順で10件ずつ返し、次ページに11件目だけを含めること' do
          params = { search: query, modified_at: 'desc' }

          expect(Post.search_by_like(user, params)).to eq posts.reverse.first(10)
          expect(Post.search_by_like(user, params.merge(page: 2))).to eq [posts.first]
          expect(Post.search_by_like(user, params.merge(page: 3))).to be_empty
        end
      end
    end
  end
end
