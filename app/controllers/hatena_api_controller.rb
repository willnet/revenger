class HatenaApiController < ApplicationController
  skip_before_filter :force_ssl
  skip_before_filter :verify_authenticity_token

  def create
    api = HatenaApi.new(params)
    unless api.add_status?
      render text: "status isn't add"
      return
    end
    unless api.valid_key?
      render text: 'invalid key'
      return
    end
    CreatePostByApiContext.call(api)
    render text: 'ok'
  end
end
