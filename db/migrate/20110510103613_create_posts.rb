class CreatePosts < ActiveRecord::Migration
  def change
    create_table :posts do |t|
      t.integer  :user_id, null: false
      t.text     :body
      t.integer  :duration, default: 1
      t.datetime :review_at
      t.datetime :modified_at, null: false
      t.timestamps
    end
    add_index :posts, [:user_id, :review_at]
    add_index :posts, [:user_id, :created_at]
    add_index :posts, [:user_id, :modified_at]
  end
end
