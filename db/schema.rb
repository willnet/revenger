# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20130409041621) do

  create_table "posts", force: true do |t|
    t.integer  "user_id",                 null: false
    t.text     "body"
    t.integer  "duration",    default: 1
    t.datetime "review_at"
    t.datetime "modified_at",             null: false
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  add_index "posts", ["user_id", "created_at"], name: "index_posts_on_user_id_and_created_at", using: :btree
  add_index "posts", ["user_id", "modified_at"], name: "index_posts_on_user_id_and_modified_at", using: :btree
  add_index "posts", ["user_id", "review_at"], name: "index_posts_on_user_id_and_review_at", using: :btree

  create_table "users", force: true do |t|
    t.string   "hatena_key",                            null: false
    t.integer  "default_duration",       default: 1
    t.string   "email",                  default: "",   null: false
    t.string   "encrypted_password",     default: "",   null: false
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.boolean  "receive_reminder",       default: true
    t.string   "unconfirmed_email"
  end

  add_index "users", ["hatena_key"], name: "index_users_on_hatena_key", using: :btree

end
