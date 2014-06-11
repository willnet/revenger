#!/bin/sh
bundle exec rake db:migrate:reset
bundle exec ruby db/dev_seeds.rb