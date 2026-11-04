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
  POST_LIST_PARAM_KEYS = %i[search created_at modified_at page].freeze

  before_action :authenticate_user!
  before_action :set_post, only: [:show, :edit, :update, :destroy]
  helper_method :post_navigation_params, :post_pagination_params

  def index
    @posts = Post.search_by_like(current_user, params)
    redirect_to_last_post_page if post_page_out_of_range?
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
    if reviewing?
      redirect_to_next_review
    elsif request.format.turbo_stream? && params[:visible_post_ids].present?
      render_post_list_after_destroy
    else
      redirect_to posts_path(post_list_params), status: :see_other
    end
  end

  private

  def set_post
    @post = current_user.posts.find(params[:id])
  end

  def post_list_params
    params.permit(*POST_LIST_PARAM_KEYS)
  end

  def post_navigation_params
    params.permit(*POST_LIST_PARAM_KEYS, :review)
  end

  # Kaminari はリクエストのパラメーターをすべてページ送りのリンクに引き継ぐため、一覧の条件以外を打ち消す。
  def post_pagination_params
    params.keys.index_with(nil).merge(post_list_params.to_h, 'controller' => 'posts', 'action' => 'index')
  end

  def post_page_out_of_range?
    @posts.out_of_range? && params[:page].to_i > 1
  end

  def redirect_to_last_post_page
    redirect_to posts_path(post_list_params.merge(page: [@posts.total_pages, 1].max)), status: :see_other
  end

  def render_post_list_after_destroy
    visible_post_ids = params.permit(visible_post_ids: []).fetch(:visible_post_ids, []).map(&:to_s)
    @remaining_post_ids = visible_post_ids - [@post.id.to_s]
    @posts = Post.search_by_like(current_user, params)

    if @remaining_post_ids.empty? && post_page_out_of_range?
      redirect_to_last_post_page
    else
      # 編集で並び順が変わった後などは 1 ページの件数を超えることがあるが、空いた件数だけに絞ると
      # このページに属するメモをページ送りでも表示できなくなるため、絞らない。
      @new_posts = @posts.reject { |post| visible_post_ids.include?(post.id.to_s) }
      render :destroy
    end
  end
end
