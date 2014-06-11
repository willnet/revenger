class ReadReviewContext
  attr_reader :next_review

  def initialize(user, params)
    @user = user
    @params = params
  end

  def self.call(user, params)
    new(user, params).call
  end

  def call
    reviewing = @user.posts.find(@params[:review][:post_id])
    reviewing.duration = @params[:review][:duration]
    reviewing.refresh_review_at
    reviewing.save!
    @next_review = @user.posts.will_be_reviewed.first
    self
  end
end
