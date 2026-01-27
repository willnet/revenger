require 'spec_helper'

describe CreatePostContext do
  describe '.call' do
    let(:post) { Post.new }
    let!(:user) { Fabricate(:user, default_duration: 7) }

    before do
      params = ActionController::Parameters.new(post: { body: '投稿本文テスト' })
      Timecop.freeze
      CreatePostContext.call(user, post, params)
      post.reload
    end

    it 'post に適切にパラメータが設定されていること' do
      expect(post.user).to eq user
      expect(post.body).to eq '投稿本文テスト'
      expect(post.modified_at).to be_the_same_time_as Time.zone.now
      expect(post.duration).to eq 7
      expect(post.review_at).to be_the_same_time_as 7.days.from_now
    end
  end
end
