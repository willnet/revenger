require 'spec_helper'

describe ApplicationController do
  include Devise::Test::ControllerHelpers

  controller do
    def index; end # template missing
  end

  context "エラーを起こしたとき" do
    it "テンプレートがない場合はエラーとして通知し、500 を返すこと" do
      expect(Rails.error).to receive(:report).with(
        an_instance_of(ActionController::MissingExactTemplate), severity: :error
      ).and_call_original

      get :index

      expect(response).to have_http_status(:internal_server_error)
      expect(response).to render_template('error500')
    end
  end
end
