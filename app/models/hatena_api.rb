class HatenaApi
  attr_reader :user

  def initialize(params)
    @params = params
  end

  def user
    @user ||= User.where(hatena_key: @params[:key]).first
  end

  def add_status?
    @params[:status] == 'add'
  end

  def valid_key?
    !!user
  end

  def bookmark_link
    "[#{@params[:title]}](#{@params[:url]})"
  end

  def body
    [bookmark_link, @params[:comment]].join("\n")
  end
end
