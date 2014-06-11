class DashboardApiController < ApplicationController
  skip_before_filter :force_ssl
  skip_before_filter :verify_authenticity_token

  def show
    hash = {user_count: User.count, post_count: Post.count }
    render json: hash
  end
end
