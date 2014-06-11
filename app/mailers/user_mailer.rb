# -*- coding: utf-8 -*-
class UserMailer < ActionMailer::Base
  default from: "noreply@revenger.in"
  add_template_helper(ApplicationHelper)

  def assignment(user)
    @user = user
    mail to: user.email, subject: '[revenger]今日のノルマ', css: :pygments
  end
end
