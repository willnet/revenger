class AddReceiveReminderToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :receive_reminder, :boolean, default: true
  end
end
