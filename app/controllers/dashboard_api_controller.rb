class DashboardApiController < ApplicationController
  skip_before_action :verify_authenticity_token

  def show
    hash = {user_count: User.count, post_count: Post.count }
    render json: hash
  end
end
