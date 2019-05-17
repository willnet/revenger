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

class Post < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection

  MAX_BODY_LENGTH = 4000 # TODO

  belongs_to :user

  validates :body,
    length: { maximum: MAX_BODY_LENGTH },
    presence: true

  scope :newer, -> { order("modified_at desc") }
  scope :older, -> { order("modified_at") }
  scope :reviewable, -> { where('review_at < ?', Time.zone.now) }
  scope :newer_by_review_at, -> { order('review_at desc')}
  scope :older_by_review_at, -> { order('review_at')}
  scope :will_be_reviewed, -> { reviewable.older_by_review_at }

  searchable do
    text    :body
    integer :user_id
    time    :modified_at
    time    :created_at
  end

  def self.search_by_solr(user, params)
    per = 10
    posts = user.posts
    if params[:search].present?
      order = [:created_at, :desc]
      if params[:created_at]
        if params[:created_at] == 'asc'
          order = [:created_at, :asc]
        elsif params[:created_at] == 'desc'
          order = [:created_at, :desc]
        end
      elsif params[:modified_at]
        if params[:modified_at] == 'asc'
          order = [:modified_at, :asc]
        elsif params[:modified_at] == 'desc'
          order = [:modified_at, :desc]
        end
      end
      posts = posts.search {
        with(:user_id, user.id)
        fulltext params[:search]
        paginate page: params[:page], per_page: per
        order_by *order
      }
      posts = posts.results
    else
      if params[:created_at]
        if params[:created_at] == 'asc'
          posts = posts.order('created_at asc')
        elsif params[:created_at] == 'desc'
          posts = posts.order('created_at desc')
        end
      elsif params[:modified_at]
        if params[:modified_at] == 'asc'
          posts = posts.order('modified_at asc')
        elsif params[:modified_at] == 'desc'
          posts = posts.order('modified_at desc')
        end
      else
        posts = posts.order('created_at desc')
      end
      posts = posts.page(params[:page]).per(per)
    end
    posts
  end

  def refresh_review_at
    self.review_at = if duration
                       duration.days.from_now
                     else
                       nil
                     end
    self
  end
end
