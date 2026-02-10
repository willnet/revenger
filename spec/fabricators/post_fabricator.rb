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

Fabricator(:post) do
  user
  body { "本文#{Fabricate.sequence :body}" }
  duration 1
  review_at { 1.day.from_now }
  modified_at { 1.day.ago }
end
