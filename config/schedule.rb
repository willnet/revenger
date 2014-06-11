# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever

set :output, "/opt/revenger/shared/log/cron_log.log"

job_type :command_with_env, "cd :path && :environment_variable=:environment :task :output"

every 1.day, :at => '1:00 am' do
  command_with_env 'backup perform --trigger db_backup --config_file /opt/revenger/shared/backup.rb --data-path db --log-path log --tmp-path tmp'
end

every 1.day, :at => '7:05 am' do
  rake 'mail:assignment'
end
