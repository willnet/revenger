#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
require File.expand_path('../../config/environment',  __FILE__)
ActiveRecord::Base.transaction do
  user = Fabricate(:user)
  puts "created #{user.inspect}"

  [["今日の天気", "晴れた"], ["今日の気分", "疲れた"], ["今日の天気", "曇り"]].each_with_index do |(title, body), i|
    Fabricate(:post, user: user, title: title, body: body, created_at: i.hours.ago, modified_at: i.hours.ago, local_id: i, read: false)
    puts "created post:#{i}"
  end
  user.last_local_id = Post.last.local_id
  user.save!
end
