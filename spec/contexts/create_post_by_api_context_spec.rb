# -*- coding: utf-8 -*-
require 'spec_helper'

describe CreatePostByApiContext do
  describe '.call' do
    context 'コンストラクタの引数が#userを持ち、保存済みのUserオブジェクトを返すとき' do
      let(:user) { Fabricate(:user) }
      let(:api) { OpenStruct.new(user: user, body: 'テスト本文') }

      it 'postsテーブルのレコードが1件増えていること' do
        expect { CreatePostByApiContext.call(api) }.to change {
          Post.count
        }.by(1)
      end

      it '最新のPostレコードの各種属性が、想定通りに設定されていること' do
        Timecop.freeze
        CreatePostByApiContext.call(api)
        post = Post.last
        expect(post.user_id).to eq user.id
        expect(post.modified_at).to be_the_same_time_as Time.zone.now
        expect(post.body).to eq 'テスト本文'
      end
    end
  end
end
