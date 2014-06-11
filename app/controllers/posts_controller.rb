# -*- coding: utf-8 -*-
class PostsController < ApplicationController
  before_filter :authenticate_user!
  respond_to :html, :json

  def index
    @posts = Post.search_by_solr(current_user, params)
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
