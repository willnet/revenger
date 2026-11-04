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

class PostsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_post, only: [:show, :edit, :update, :destroy]
  helper_method :post_navigation_params

  def index
    @posts = Post.search_by_like(current_user, params)
    if @posts.out_of_range? && params[:page].to_i > 1
      redirect_to posts_path(post_navigation_params.merge(page: [@posts.total_pages, 1].max))
    end
  end

  def show; end
  def edit; end

  def new
    @post = Post.new
  end

  def create
    @post = current_user.posts.build
    if CreatePostContext.call(current_user, @post, params)
      redirect_to posts_path, notice: '作成しました', status: :see_other
    else
      render :new, status: :unprocessable_content
    end
  end

  def update
    if UpdatePostContext.call(@post, params)
      redirect_to post_path(@post, post_navigation_params), status: :see_other
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @post.destroy!
    if params[:review] == 'true'
      redirect_to review_path(completed: true), status: :see_other
    elsif request.format.turbo_stream? && params[:visible_post_ids].present?
      render_post_list_after_destroy
    else
      redirect_to posts_path(post_navigation_params.except(:review)), status: :see_other
    end
  end

  private

  def set_post
    @post = current_user.posts.find(params[:id])
  end

  def post_navigation_params
    params.permit(:search, :created_at, :modified_at, :page, :review)
  end

  def render_post_list_after_destroy
    visible_post_ids = params.permit(visible_post_ids: []).fetch(:visible_post_ids, []).map(&:to_s)
    @remaining_post_ids = visible_post_ids - [@post.id.to_s]
    @posts = Post.search_by_like(current_user, params)

    if @remaining_post_ids.empty? && @posts.out_of_range? && params[:page].to_i > 1
      redirect_to posts_path(post_navigation_params.except(:review).merge(page: [@posts.total_pages, 1].max)), status: :see_other
    else
      @new_posts = @posts.reject { |post| visible_post_ids.include?(post.id.to_s) }
      render :destroy
    end
  end
end
