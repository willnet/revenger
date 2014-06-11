class AddReceiveReminderToUsers < ActiveRecord::Migration
  def change
    add_column :users, :receive_reminder, :boolean, default: true
  end
end
