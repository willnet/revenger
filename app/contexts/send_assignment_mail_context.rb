class SendAssignmentMailContext
  def self.call
    new.call
  end

  def call
    User.confirmed.where(receive_reminder: true).includes(:reviewable_posts).find_each do |user|
      if user.reviewable_posts.exists?
        UserMailer.assignment(user).deliver
      end
    end
  end
end
