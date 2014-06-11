# -*- coding: utf-8 -*-
require 'spec_helper'

describe ApplicationController do
  controller do
    def index; end # template missing
  end

  context "エラーを起こしたとき" do
    it "error500 を表示すること" do
      get :index
      expect(response).to render_template('error500')
    end
  end
end
