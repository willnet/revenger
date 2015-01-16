class Api::SessionsController < ApplicationController
  skip_before_filter :verify_authenticity_token

  def create
    if params[:email] == 'hoge' && params[:password] == 'fuga'
      render json: { token: 'hogehoge' }
    else
      render json: { messages: 'Invalid email or password' }, status: 401
    end
  end
end
