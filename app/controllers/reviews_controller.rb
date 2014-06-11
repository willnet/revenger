class ReviewsController < ApplicationController
  before_filter :authenticate_user!

  def show
    @post = current_user.posts.will_be_reviewed.first
    @count = current_user.posts.reviewable.count
  end

  def next
    @post = current_user.posts.will_be_reviewed.first
  end

  def create
    context = ReadReviewContext.call(current_user, params)
    @next_review = context.next_review
  end

  def count
    count = current_user.posts.reviewable.count
    render json: {count: count}
  end
end
