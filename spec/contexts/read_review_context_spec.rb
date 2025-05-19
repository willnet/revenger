require 'spec_helper'

describe ReadReviewContext do
  describe '.call' do
    context '3種類の復習メモ(復習ノルマ)があるとき' do
      let(:user) { Fabricate(:user) }

      before do
        @post1 = Fabricate(:post, user: user, review_at: 1.day.ago)
        @post2 = Fabricate(:post, user: user, review_at: 2.day.ago)
        @post3 = Fabricate(:post, user: user, review_at: 3.day.ago)
      end

      context 'かつ params が正しく設定されているとき' do
        let(:params) do
          ActionController::Parameters.new(review: {
              post_id: @post3.id,
              duration: 7
            }
          )
        end

        it '#next_review に次に復習すべき復習メモがセットされていること' do
          context = ReadReviewContext.call(user, params)
          expect(context.next_review).to eq @post2
        end

        it 'post_id に指定されていた復習メモの #review_at が #duration 日後に設定されていること' do
          Timecop.freeze
          ReadReviewContext.call(user, params)
          post = @post3.reload
          expect(post.review_at).to be_the_same_time_as post.duration.days.from_now
        end
      end
    end
  end
end
