class CreatePostByApiContext
  def initialize(api)
    @api = api
  end

  def self.call(api)
    new(api).call
  end

  def call
    post = @api.user.posts.build(body: @api.body)
    post.modified_at = Time.zone.now
    post.save!
  end
end
