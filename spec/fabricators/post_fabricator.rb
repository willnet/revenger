# -*- coding: utf-8 -*-
# == Schema Information
#
# Table name: posts
#
#  id          :integer          not null, primary key
#  user_id     :integer          not null
#  body        :text(65535)
#  duration    :integer          default(1)
#  review_at   :datetime
#  modified_at :datetime         not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

Fabricator(:post) do
  user
  body { "本文#{Fabricate.sequence :body}" }
  duration 1
  review_at { 1.day.from_now }
  modified_at { 1.day.ago }
end
