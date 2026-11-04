class ReviewsController < ApplicationController
  before_action :authenticate_user!

  def show
    @post = current_user.posts.will_be_reviewed.first
    @count = current_user.posts.reviewable.count
  end

  def create
    ReadReviewContext.call(current_user, params)
    redirect_to_next_review
  end
end
