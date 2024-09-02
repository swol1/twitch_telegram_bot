# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2024_09_02_213908) do
  create_table "chat_streamer_subscriptions", force: :cascade do |t|
    t.integer "chat_id", null: false
    t.integer "streamer_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["chat_id", "streamer_id"], name: "index_chat_streamer_subscriptions_on_chat_id_and_streamer_id", unique: true
    t.index ["chat_id"], name: "index_chat_streamer_subscriptions_on_chat_id"
    t.index ["streamer_id"], name: "index_chat_streamer_subscriptions_on_streamer_id"
  end

  create_table "chats", force: :cascade do |t|
    t.string "locale", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "telegram_id", null: false
    t.boolean "just_chatting_mode", default: false
    t.index ["telegram_id"], name: "index_chats_on_telegram_id", unique: true
  end

  create_table "event_subscriptions", force: :cascade do |t|
    t.string "event_type", null: false
    t.string "streamer_twitch_id", null: false
    t.string "version", null: false
    t.integer "status", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "twitch_id", null: false
    t.index ["streamer_twitch_id", "event_type"], name: "index_event_subscriptions_on_streamer_twitch_id_and_event_type", unique: true
    t.index ["twitch_id"], name: "index_event_subscriptions_on_twitch_id", unique: true
  end

  create_table "streamers", force: :cascade do |t|
    t.string "login", null: false
    t.string "name", null: false
    t.string "twitch_id", null: false
    t.string "telegram_login"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["login"], name: "index_streamers_on_login", unique: true
    t.index ["telegram_login"], name: "index_streamers_on_telegram_login", unique: true
    t.index ["twitch_id"], name: "index_streamers_on_twitch_id", unique: true
  end

  add_foreign_key "chat_streamer_subscriptions", "chats"
  add_foreign_key "chat_streamer_subscriptions", "streamers"
end
