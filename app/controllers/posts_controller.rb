# -*- coding: utf-8 -*-
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
  respond_to :html, :json

  def index
    @posts = Post.search_by_like(current_user, params)
  end

  def new
    @post = Post.new
  end

  def create
    @post = current_user.posts.build
    if CreatePostContext.call(current_user, @post, params)
      redirect_to posts_path, notice: '作成しました'
    else
      render action: :new
    end
  end

  def update
    @post = current_user.posts.find(params[:id])
    unless UpdatePostContext.call(@post, params)
      render json: { errors: @post.errors }, status: 422
    end
  end

  def destroy
    @post = current_user.posts.find(params[:id])
    @post.destroy
    respond_with @post
  end
end
