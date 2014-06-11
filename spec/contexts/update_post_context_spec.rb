# -*- coding: utf-8 -*-
require 'spec_helper'

describe UpdatePostContext do
  describe '.call' do
    context '引数が正しいとき' do
      let(:post) { Fabricate(:post) }
      let(:params) { ActionController::Parameters.new(post: { body: 'メモ本文', duration: 7 }) }

      it 'true が返ること' do
        expect(UpdatePostContext.call(post, params)).to be_true
      end

      it '引数として渡した post に正しい属性のPostオブジェクトがセットされていること' do
        Timecop.freeze
        context = UpdatePostContext.call(post, params)
        post.reload
        expect(post.body).to eq 'メモ本文'
        expect(post.duration).to eq 7
        expect(post.modified_at).to be_the_same_time_as Time.zone.now
      end
    end
  end
end
