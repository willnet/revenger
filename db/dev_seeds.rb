#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
require File.expand_path('../../config/environment',  __FILE__)
ActiveRecord::Base.transaction do
  user = Fabricate(:user)
  puts "created #{user.inspect}"

  [["今日の天気", "晴れた"], ["今日の気分", "疲れた"], ["今日の天気", "曇り"]].each_with_index do |(title, body), i|
    Fabricate(:post, user: user, body: body, created_at: i.hours.ago, modified_at: i.hours.ago)
    puts "created post:#{i}"
  end
  user.save!
end
