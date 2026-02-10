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

    it { is_expected.to accept_values_for(:body, "hoge", "!!!!!!", 'ほげほげ') }
    it "#{Post::MAX_BODY_LENGTH + 1}文字のとき invalid になること" do
      is_expected.not_to accept_values_for(:body, "", "a" * (Post::MAX_BODY_LENGTH + 1))
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

    it 'アルファベットの検索がどうなるか' do
      skip
    end
  end
end
