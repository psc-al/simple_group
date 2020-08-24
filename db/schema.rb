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

ActiveRecord::Schema.define(version: 2020_08_23_233944) do

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

  create_table "inbox_items", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "inboxable_type", null: false
    t.bigint "inboxable_id", null: false
    t.boolean "read", default: false, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["inboxable_type", "inboxable_id"], name: "index_inbox_items_on_inboxable_type_and_inboxable_id"
    t.index ["user_id", "read"], name: "index_inbox_items_on_user_id_and_read"
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

  create_table "thread_replies", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "comment_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["comment_id"], name: "index_thread_replies_on_comment_id"
    t.index ["user_id"], name: "index_thread_replies_on_user_id"
  end

  create_table "user_invitations", force: :cascade do |t|
    t.bigint "sender_id", null: false
    t.string "recipient_email", null: false
    t.bigint "recipient_id"
    t.datetime "sent_at"
    t.datetime "accepted_at"
    t.string "token", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index "lower((recipient_email)::text)", name: "index_user_invitations_on_LOWER_recipient_email", unique: true, where: "(lower((recipient_email)::text) <> '[deleted]'::text)"
    t.index ["recipient_id"], name: "index_user_invitations_on_recipient_id"
    t.index ["sender_id"], name: "index_user_invitations_on_sender_id"
    t.index ["token"], name: "index_user_invitations_on_token", unique: true
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
    t.index "lower((email)::text)", name: "index_users_on_LOWER_email", unique: true, where: "(lower((email)::text) <> '[deleted]'::text)"
    t.index "lower((username)::text)", name: "index_users_on_LOWER_username", unique: true, where: "(lower((username)::text) <> '[deleted]'::text)"
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
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id", "votable_type", "votable_id"], name: "idx_uniq_votes_user_and_votable", unique: true
    t.index ["votable_type", "votable_id", "kind"], name: "index_votes_on_votable_type_and_votable_id_and_kind"
  end

  add_foreign_key "comments", "comments", column: "parent_id", on_delete: :cascade
  add_foreign_key "comments", "submissions", on_delete: :cascade
  add_foreign_key "comments", "users", on_delete: :cascade
  add_foreign_key "domains", "users", column: "banned_by_id"
  add_foreign_key "inbox_items", "users", on_delete: :cascade
  add_foreign_key "submission_actions", "submissions", column: "submission_short_id", primary_key: "short_id"
  add_foreign_key "submission_actions", "users", on_delete: :cascade
  add_foreign_key "submission_tags", "submissions", on_delete: :cascade
  add_foreign_key "submission_tags", "tags", on_delete: :cascade
  add_foreign_key "submissions", "domains"
  add_foreign_key "submissions", "users"
  add_foreign_key "thread_replies", "comments", on_delete: :cascade
  add_foreign_key "thread_replies", "users", on_delete: :cascade
  add_foreign_key "user_invitations", "users", column: "recipient_id", on_delete: :cascade
  add_foreign_key "user_invitations", "users", column: "sender_id", on_delete: :cascade
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
      ( SELECT count(comments.submission_id) AS comment_count
             FROM comments
            WHERE (comments.submission_id = submissions.id)) AS comment_count,
      (( SELECT count(votes.votable_id) AS count
             FROM votes
            WHERE (((votes.votable_type)::text = 'Submission'::text) AND (votes.votable_id = submissions.id) AND (votes.kind = 0))) - ( SELECT count(votes.votable_id) AS count
             FROM votes
            WHERE (((votes.votable_type)::text = 'Submission'::text) AND (votes.votable_id = submissions.id) AND (votes.kind = 1)))) AS score
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
      ( SELECT count(comments.submission_id) AS comment_count
             FROM comments
            WHERE (comments.submission_id = submissions.id)) AS comment_count,
      (( SELECT count(votes.votable_id) AS count
             FROM votes
            WHERE (((votes.votable_type)::text = 'Submission'::text) AND (votes.votable_id = submissions.id) AND (votes.kind = 0))) - ( SELECT count(votes.votable_id) AS count
             FROM votes
            WHERE (((votes.votable_type)::text = 'Submission'::text) AND (votes.votable_id = submissions.id) AND (votes.kind = 1)))) AS score
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
      users.username AS commenter,
      (( SELECT count(votes.votable_id) AS count
             FROM votes
            WHERE (((votes.votable_type)::text = 'Comment'::text) AND (votes.votable_id = comments.id) AND (votes.kind = 0))) - ( SELECT count(votes.votable_id) AS count
             FROM votes
            WHERE (((votes.votable_type)::text = 'Comment'::text) AND (votes.votable_id = comments.id) AND (votes.kind = 1)))) AS score
     FROM (comments
       JOIN users ON ((users.id = comments.user_id)));
  SQL
  create_view "flattened_inbox_items", sql_definition: <<-SQL
      SELECT submissions.title AS toplevel_subject,
      'Submission'::text AS toplevel_type,
      submissions.short_id AS toplevel_short_id,
      inbox_items.user_id,
      users.username AS actor_username,
      'CommentReply'::text AS item_type,
      comments.short_id AS item_short_id,
      comments.body AS item_body,
      inbox_items.read,
      thread_replies.created_at AS inboxed_at
     FROM ((((inbox_items
       JOIN thread_replies ON ((((inbox_items.inboxable_type)::text = 'ThreadReply'::text) AND (inbox_items.inboxable_id = thread_replies.id))))
       JOIN comments ON ((thread_replies.comment_id = comments.id)))
       JOIN submissions ON ((comments.submission_id = submissions.id)))
       JOIN users ON ((comments.user_id = users.id)))
    WHERE (comments.parent_id IS NOT NULL)
  UNION ALL
   SELECT submissions.title AS toplevel_subject,
      'Submission'::text AS toplevel_type,
      submissions.short_id AS toplevel_short_id,
      inbox_items.user_id,
      users.username AS actor_username,
      'SubmissionReply'::text AS item_type,
      comments.short_id AS item_short_id,
      comments.body AS item_body,
      inbox_items.read,
      thread_replies.created_at AS inboxed_at
     FROM ((((inbox_items
       JOIN thread_replies ON ((((inbox_items.inboxable_type)::text = 'ThreadReply'::text) AND (inbox_items.inboxable_id = thread_replies.id))))
       JOIN comments ON ((thread_replies.comment_id = comments.id)))
       JOIN submissions ON ((comments.submission_id = submissions.id)))
       JOIN users ON ((comments.user_id = users.id)))
    WHERE (comments.parent_id IS NULL);
  SQL
end
