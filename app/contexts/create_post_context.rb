class CreatePostContext

  def initialize(user, post, params)
    @user = user
    @post = post
    @params = params
  end

  def self.call(user, post, params)
    new(user, post, params).call
  end

  def call
    @post.user_id = @user.id
    @post.body = @params[:post][:body]
    @post.modified_at = Time.zone.now
    @post.duration = @user.default_duration
    @post.refresh_review_at
    @post.save
  end
end
