# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  hatena_key             :string(255)      not null
#  default_duration       :integer          default(1)
#  email                  :string(255)      default(""), not null
#  encrypted_password     :string(255)      default(""), not null
#  confirmation_token     :string(255)
#  confirmed_at           :datetime
#  confirmation_sent_at   :datetime
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0)
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string(255)
#  last_sign_in_ip        :string(255)
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  receive_reminder       :boolean          default(TRUE)
#  unconfirmed_email      :string(255)
#

Fabricator(:user) do
  email { "netwillnet#{Fabricate.sequence :email}@gmail.com" }
  password { "password" }
  # posts(:count => 100) { |user, i| Fabricate(:post, :title => "タイトル#{i}", :body => "本文#{i}", :local_id => i, :user => user)}
  before_create { |user| User.skip_callback(:create, :before, :build_initial_posts) }
  after_create { |user| user.confirm; User.set_callback(:create, :before, :build_initial_posts) }
end
