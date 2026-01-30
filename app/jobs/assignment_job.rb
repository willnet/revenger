class AssignmentJob < ApplicationJob
  queue_as :default

  def perform(*args)
    SendAssignmentMailContext.call
  end
end
