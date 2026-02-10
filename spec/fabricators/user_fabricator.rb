# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  confirmation_sent_at   :datetime
#  confirmation_token     :string
#  confirmed_at           :datetime
#  current_sign_in_at     :datetime
#  current_sign_in_ip     :string
#  default_duration       :integer          default(1)
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  last_sign_in_at        :datetime
#  last_sign_in_ip        :string
#  receive_reminder       :boolean          default(TRUE)
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  sign_in_count          :integer          default(0)
#  unconfirmed_email      :string
#  created_at             :datetime
#  updated_at             :datetime
#

Fabricator(:user) do
  email { "netwillnet#{Fabricate.sequence :email}@gmail.com" }
  password { "password" }
  # posts(:count => 100) { |user, i| Fabricate(:post, :title => "タイトル#{i}", :body => "本文#{i}", :local_id => i, :user => user)}
  before_create { |user| User.skip_callback(:create, :before, :build_initial_posts) }
  after_create { |user| user.confirm; User.set_callback(:create, :before, :build_initial_posts) }
end
