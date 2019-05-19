class HatenaApiController < ApplicationController
  skip_before_action :force_ssl
  skip_before_action :verify_authenticity_token

  def create
    api = HatenaApi.new(params)
    unless api.add_status?
      render plain: "status isn't add"
      return
    end
    unless api.valid_key?
      render plain: 'invalid key'
      return
    end
    CreatePostByApiContext.call(api)
    render plain: 'ok'
  end
end
