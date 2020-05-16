# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_05_16_200636) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "domains", force: :cascade do |t|
    t.string "name", null: false
    t.boolean "tracker", default: false, null: false
    t.datetime "banned_at"
    t.bigint "banned_by_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["banned_by_id"], name: "index_domains_on_banned_by_id", where: "(banned_by_id IS NOT NULL)"
    t.index ["name"], name: "index_domains_on_name", unique: true
  end

  create_table "submissions", force: :cascade do |t|
    t.string "title", limit: 175, null: false
    t.string "url"
    t.text "body"
    t.bigint "user_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "original_author", default: false, null: false
    t.bigint "domain_id"
    t.string "short_id", null: false
    t.index ["domain_id"], name: "index_submissions_on_domain_id", where: "(domain_id IS NOT NULL)"
    t.index ["short_id"], name: "index_submissions_on_short_id", unique: true
    t.index ["url"], name: "index_submissions_on_url", unique: true, where: "(url IS NOT NULL)"
    t.index ["user_id"], name: "index_submissions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "role", default: 0, null: false
    t.string "username", limit: 20, null: false
    t.datetime "last_submission_at"
    t.index "lower((email)::text)", name: "index_users_on_LOWER_email", unique: true
    t.index "lower((username)::text)", name: "index_users_on_LOWER_username", unique: true
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["role"], name: "index_users_on_role"
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true
  end

  add_foreign_key "domains", "users", column: "banned_by_id"
  add_foreign_key "submissions", "domains"
  add_foreign_key "submissions", "users"
end
