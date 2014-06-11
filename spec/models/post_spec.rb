# -*- coding: utf-8 -*-
# == Schema Information
#
# Table name: posts
#
#  id          :integer          not null, primary key
#  user_id     :integer          not null
#  body        :text
#  duration    :integer          default(1)
#  review_at   :datetime
#  modified_at :datetime         not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

require 'spec_helper'

describe Post do

  describe '#body' do
    subject { Fabricate.build(:post) }

    it { should accept_values_for(:body, "hoge", "!!!!!!", 'ほげほげ') }
    it "#{Post::MAX_BODY_LENGTH + 1}文字のとき invalid になること" do
      should_not accept_values_for(:body, "", "a" * (Post::MAX_BODY_LENGTH + 1))
    end
  end

  context ".search_by_solr", solr: true do
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
      Post.index
    end

    context "user, {}" do
      subject { Post.search_by_solr(@user, {}).map(&:body) }
      it '作成日降順でオブジェクトの配列が返ること' do
        should eq ['ほげ3-2', 'ふが4-3', 'ふが5-1', 'ふが24-24']
      end
    end

    context "user, {created_at: 'asc'}" do
      subject { Post.search_by_solr(@user, {created_at: 'asc'}).map(&:body) }
      it '作成日昇順でオブジェクトの配列が返ること' do
        should eq ['ふが24-24', 'ふが5-1', 'ふが4-3', 'ほげ3-2']
      end
    end

    context "user, {search: '', created_at: 'asc'}" do
      subject { Post.search_by_solr(@user, {search: '', created_at: 'asc'}).map(&:body) }
      it '作成日昇順でオブジェクトの配列が返ること' do
        should eq ['ふが24-24', 'ふが5-1', 'ふが4-3', 'ほげ3-2']
      end
    end

    context "user, {search: '', created_at: 'desc'}" do
      subject { Post.search_by_solr(@user, {search: '', created_at: 'desc'}).map(&:body) }
      it '作成日降順でオブジェクトの配列が返ること' do
        should eq ['ほげ3-2', 'ふが4-3', 'ふが5-1', 'ふが24-24']
      end
    end

    context "user, {search: '', created_at: 'asc'}" do
      subject { Post.search_by_solr(@user, {search: '', created_at: 'desc'}).map(&:body) }
      it '作成日降順でオブジェクトの配列が返ること' do
        should eq ['ほげ3-2', 'ふが4-3', 'ふが5-1', 'ふが24-24']
      end
    end

    context "user, {modified_at: 'asc'}" do
      subject { Post.search_by_solr(@user, {modified_at: 'asc'}).map(&:body) }
      it '更新日昇順でオブジェクトの配列が返ること' do
        should eq ['ふが24-24', 'ふが4-3', 'ほげ3-2', 'ふが5-1']
      end
    end

    context "user, {search: '', modified_at: 'asc'}" do
      subject { Post.search_by_solr(@user, {search: '', modified_at: 'asc'}).map(&:body) }
      it '更新日昇順でオブジェクトの配列が返ること' do
        should eq ['ふが24-24', 'ふが4-3', 'ほげ3-2', 'ふが5-1']
      end
    end

    context "user, {modified_at: 'desc'}" do
      subject { Post.search_by_solr(@user, {modified_at: 'desc'}).map(&:body) }
      it '更新日降順でオブジェクトの配列が返ること' do
        should eq ['ふが5-1', 'ほげ3-2', 'ふが4-3', 'ふが24-24']
      end
    end

    context "user, {search: '', modified_at: 'desc'}" do
      subject { Post.search_by_solr(@user, {search: '', modified_at: 'desc'}).map(&:body) }
      it '更新日昇順でオブジェクトの配列が返ること' do
        should eq ['ふが5-1', 'ほげ3-2', 'ふが4-3', 'ふが24-24']
      end
    end

    context "{search: 'ふが'}" do
      subject { Post.search_by_solr(@user, {search: 'ふが'}).map(&:body) }
      it '"ふが"を含むオブジェクトの配列が作成日降順で返ること' do
        should eq ['ふが4-3', 'ふが5-1', 'ふが24-24']
      end
    end

    context "{search: 'ふが', created_at: 'asc'}" do
      subject { Post.search_by_solr(@user, {search: 'ふが', created_at: 'asc'}).map(&:body) }
      it '"ふが"を含むオブジェクトの配列が作成日昇順で返ること' do
        should eq ['ふが24-24', 'ふが5-1', 'ふが4-3']
      end
    end

    context "{search: 'ふが', created_at: 'desc'}" do
      subject { Post.search_by_solr(@user, {search: 'ふが', created_at: 'desc'}).map(&:body) }
      it '"ふが"を含むオブジェクトの配列が作成日降順で返ること' do
        should eq ['ふが4-3', 'ふが5-1', 'ふが24-24']
      end
    end

    context "{search: 'ふが', modified_at: 'asc'}" do
      subject { Post.search_by_solr(@user, {search: 'ふが', modified_at: 'asc'}).map(&:body) }
      it '"ふが"を含むオブジェクトの配列が更新日昇順で返ること' do
        should eq ['ふが24-24', 'ふが4-3', 'ふが5-1']
      end
    end

    context "{search: 'ふが', modified_at: 'desc'}" do
      subject { Post.search_by_solr(@user, {search: 'ふが', modified_at: 'desc'}).map(&:body) }
      it '"ふが"を含むオブジェクトの配列が更新日降順で返ること' do
        should eq ['ふが5-1', 'ふが4-3', 'ふが24-24']
      end
    end

    it 'アルファベットの検索がどうなるか' do
      pending
    end
  end
end
