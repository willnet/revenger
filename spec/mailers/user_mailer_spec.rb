# -*- coding: utf-8 -*-
require "spec_helper"

describe UserMailer do
  describe "assignment" do
    let(:mail) { UserMailer.assignment(user) }
    let(:user) { Fabricate(:user) }

    before { Fabricate(:post, user: user, review_at: 1.day.ago)}

    it "renders the headers" do
      mail.subject.should eq("[revenger]今日のノルマ")
      mail.to.should eq([user.email])
      mail.from.should eq(["noreply@revenger.in"])
    end

    it "renders the body" do
      mail.body.encoded.should match("今日も張り切って復習しましょう！")
    end
  end
end
