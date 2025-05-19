require 'spec_helper'

describe SendAssignmentMailContext do
  describe '.call' do
    before do
      @reminded_user1 = Fabricate(:user, receive_reminder: true)
      Fabricate(:post, user: @reminded_user1, review_at: 1.day.ago)
      reminded_user2 = Fabricate(:user, receive_reminder: true)
      not_reminded_user = Fabricate(:user, receive_reminder: false)
    end

    it 'メールが一通送信されていること' do
      expect { SendAssignmentMailContext.call }.
        to change { ActionMailer::Base.deliveries.length }.by(1)
    end

    it '送信されているメールの宛先が、レビュー可能な投稿を持ち、かつメール送信設定がオンのユーザであること' do
      SendAssignmentMailContext.call
      expect(ActionMailer::Base.deliveries.last.to).to eq [@reminded_user1.email]
    end
  end
end
