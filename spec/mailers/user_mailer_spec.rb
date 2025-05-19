require "spec_helper"

describe UserMailer do
  describe "assignment" do
    let(:mail) { UserMailer.assignment(user) }
    let(:user) { Fabricate(:user) }

    before { Fabricate(:post, user: user, review_at: 1.day.ago)}

    it "renders the headers" do
      expect(mail.subject).to eq("[revenger]今日のノルマ")
      expect(mail.to).to eq([user.email])
      expect(mail.from).to eq(["noreply@revenger.in"])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("今日も張り切って復習しましょう！")
    end
  end
end
