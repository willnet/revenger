# -*- coding: utf-8 -*-
require 'spec_helper'

describe 'POST /api/hatena' do
  let(:user) { Fabricate(:user) }
  context "パラメータが正しいとき" do
    before do
      post('/api/hatena',
        status: 'add',
        key: user.hatena_key,
        comment: 'ほげ',
        title: 'willnet.in',
        url: 'http://willnet.in'
      )
    end
    subject { response }
    its(:status) { should be(200) }
    its(:body) { should eq 'ok' }
  end

  context "status が 'update' のとき" do
    before do
      post('/api/hatena',
        status: 'update',
        key: user.hatena_key,
        comment: 'ほげ',
        title: 'willnet.in',
        url: 'http://willnet.in'
      )
    end
    subject { response }
    its(:status) { should be(200) }
    its(:body) { should eq "status isn't add" }
  end

  context "key が 'xxx' のとき" do
    before do
      post('/api/hatena',
        status: 'add',
        key: 'xxx',
        comment: 'ほげ',
        title: 'willnet.in',
        url: 'http://willnet.in'
      )
    end
    subject { response }
    its(:status) { should be(200) }
    its(:body) { should eq 'invalid key' }
  end
end
