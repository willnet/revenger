class UpdatePostContext
  def initialize(post, params)
    @post = post
    @params = params
  end

  def self.call(post, params)
    new(post, params).call
  end

  def call
    @post.attributes = @params.require(:post).permit(:body, :duration)
    @post.modified_at = Time.zone.now
    @post.save
  end
end
