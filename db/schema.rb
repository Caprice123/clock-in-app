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

ActiveRecord::Schema[7.1].define(version: 2025_09_07_103427) do
  create_table "follows", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "followed_user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["followed_user_id"], name: "index_follows_on_followed_user_id"
    t.index ["user_id", "followed_user_id"], name: "index_follows_on_user_id_and_followed_user_id", unique: true
  end

  create_table "sleep_records", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "aasm_state", null: false, default: "sleeping"
    t.datetime "sleep_time", null: false, default: -> { "CURRENT_TIMESTAMP" }
    t.datetime "wake_time"
    t.integer "duration"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "aasm_state", "duration"], name: "index_sleep_records_on_user_id_and_aasm_state_and_duration"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_users_on_name", unique: true
  end

end
