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

ActiveRecord::Schema.define(version: 2020_05_21_044543) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "ltree"
  enable_extension "plpgsql"

  create_table "comments", force: :cascade do |t|
    t.string "short_id", null: false
    t.bigint "user_id", null: false
    t.bigint "submission_id", null: false
    t.bigint "parent_id"
    t.text "body", null: false
    t.ltree "ancestry_path"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["ancestry_path"], name: "index_comments_on_ancestry_path", using: :gist
    t.index ["parent_id"], name: "index_comments_on_parent_id"
    t.index ["short_id"], name: "index_comments_on_short_id", unique: true
    t.index ["submission_id"], name: "index_comments_on_submission_id"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

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

  create_table "submission_actions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "submission_short_id", null: false
    t.integer "kind", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["kind"], name: "index_submission_actions_on_kind"
    t.index ["submission_short_id"], name: "index_submission_actions_on_submission_short_id"
    t.index ["user_id", "kind", "submission_short_id"], name: "idx_unique_submission_actions", unique: true
  end

  create_table "submission_tags", force: :cascade do |t|
    t.bigint "submission_id", null: false
    t.text "tag_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["submission_id"], name: "index_submission_tags_on_submission_id"
    t.index ["tag_id"], name: "index_submission_tags_on_tag_id"
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

  create_table "tags", id: :string, force: :cascade do |t|
    t.string "description", limit: 100
    t.integer "kind", default: 0, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
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

  create_table "votes", force: :cascade do |t|
    t.string "votable_type", null: false
    t.bigint "votable_id", null: false
    t.bigint "user_id", null: false
    t.integer "kind", null: false
    t.integer "downvote_reason"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id", "votable_type", "votable_id", "kind"], name: "idx_uniq_votes_user_votable_and_kind", unique: true
    t.index ["votable_type", "votable_id", "kind"], name: "index_votes_on_votable_type_and_votable_id_and_kind"
  end

  add_foreign_key "comments", "comments", column: "parent_id", on_delete: :cascade
  add_foreign_key "comments", "submissions", on_delete: :cascade
  add_foreign_key "comments", "users", on_delete: :cascade
  add_foreign_key "domains", "users", column: "banned_by_id"
  add_foreign_key "submission_actions", "submissions", column: "submission_short_id", primary_key: "short_id"
  add_foreign_key "submission_actions", "users", on_delete: :cascade
  add_foreign_key "submission_tags", "submissions", on_delete: :cascade
  add_foreign_key "submission_tags", "tags", on_delete: :cascade
  add_foreign_key "submissions", "domains"
  add_foreign_key "submissions", "users"
  add_foreign_key "votes", "users", on_delete: :cascade

  create_view "flattened_submissions", sql_definition: <<-SQL
      SELECT submissions.id,
      submissions.short_id,
      submissions.title,
      submissions.url,
      domains.name AS domain_name,
      NULL::text AS body,
      users.username AS submitter_username,
      submissions.original_author,
      submissions.created_at,
      COALESCE(( SELECT count(comments.submission_id) AS comment_count
             FROM comments
            WHERE (comments.submission_id = submissions.id)
            GROUP BY comments.submission_id), (0)::bigint) AS comment_count
     FROM ((submissions
       JOIN users ON ((submissions.user_id = users.id)))
       JOIN domains ON ((submissions.domain_id = domains.id)))
    WHERE (submissions.domain_id IS NOT NULL)
  UNION ALL
   SELECT submissions.id,
      submissions.short_id,
      submissions.title,
      NULL::character varying AS url,
      NULL::character varying AS domain_name,
      submissions.body,
      users.username AS submitter_username,
      submissions.original_author,
      submissions.created_at,
      COALESCE(( SELECT count(comments.submission_id) AS comment_count
             FROM comments
            WHERE (comments.submission_id = submissions.id)
            GROUP BY comments.submission_id), (0)::bigint) AS comment_count
     FROM (submissions
       JOIN users ON ((submissions.user_id = users.id)))
    WHERE (submissions.domain_id IS NULL);
  SQL
  create_view "flattened_comments", sql_definition: <<-SQL
      SELECT comments.id,
      comments.short_id,
      comments.submission_id,
      comments.parent_id,
      comments.body,
      comments.created_at,
      comments.updated_at,
      users.username AS commenter
     FROM (comments
       JOIN users ON ((users.id = comments.user_id)));
  SQL
end
