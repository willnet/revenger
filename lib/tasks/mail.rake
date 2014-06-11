namespace :mail do
  desc "send user's assignment list"
  task :assignment => :environment do
    SendAssignmentMailContext.call
  end
end
