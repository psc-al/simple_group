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

ActiveRecord::Schema.define(version: 2020_10_24_182216) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "ltree"
  enable_extension "plpgsql"

  create_table "comment_removals", force: :cascade do |t|
    t.bigint "comment_id", null: false
    t.bigint "removed_by_id", null: false
    t.integer "reason", null: false
    t.text "details"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["comment_id"], name: "index_comment_removals_on_comment_id", unique: true
  end

  create_table "comments", force: :cascade do |t|
    t.string "short_id", null: false
    t.bigint "user_id", null: false
    t.bigint "submission_id", null: false
    t.bigint "parent_id"
    t.text "body", null: false
    t.ltree "ancestry_path"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "removed", default: false, null: false
    t.index ["ancestry_path"], name: "index_comments_on_ancestry_path", using: :gist
    t.index ["parent_id"], name: "index_comments_on_parent_id"
    t.index ["removed"], name: "index_comments_on_removed"
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

  create_table "submission_removals", force: :cascade do |t|
    t.bigint "submission_id", null: false
    t.bigint "removed_by_id", null: false
    t.integer "reason", null: false
    t.text "details"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["submission_id"], name: "index_submission_removals_on_submission_id", unique: true
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
    t.boolean "removed", default: false, null: false
    t.index ["domain_id"], name: "index_submissions_on_domain_id", where: "(domain_id IS NOT NULL)"
    t.index ["removed"], name: "index_submissions_on_removed"
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

  create_table "thread_reply_notifications", force: :cascade do |t|
    t.bigint "recipient_id", null: false
    t.bigint "in_response_to_comment_id"
    t.bigint "reply_id", null: false
    t.boolean "dismissed", default: false, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["dismissed"], name: "index_thread_reply_notifications_on_dismissed"
    t.index ["in_response_to_comment_id"], name: "index_thread_reply_notifications_on_in_response_to_comment_id"
    t.index ["recipient_id"], name: "index_thread_reply_notifications_on_recipient_id"
    t.index ["reply_id"], name: "index_thread_reply_notifications_on_reply_id"
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
    t.bigint "banned_by_id"
    t.datetime "banned_at"
    t.integer "ban_type"
    t.text "ban_reason"
    t.datetime "temp_ban_end_at"
    t.datetime "unbanned_at"
    t.index "lower((email)::text)", name: "index_users_on_LOWER_email", unique: true, where: "(lower((email)::text) <> '[deleted]'::text)"
    t.index "lower((username)::text)", name: "index_users_on_LOWER_username", unique: true, where: "(lower((username)::text) <> '[deleted]'::text)"
    t.index ["banned_by_id"], name: "index_users_on_banned_by_id"
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

  add_foreign_key "comment_removals", "comments", on_delete: :cascade
  add_foreign_key "comment_removals", "users", column: "removed_by_id", on_delete: :cascade
  add_foreign_key "comments", "comments", column: "parent_id", on_delete: :cascade
  add_foreign_key "comments", "submissions", on_delete: :cascade
  add_foreign_key "comments", "users", on_delete: :cascade
  add_foreign_key "domains", "users", column: "banned_by_id"
  add_foreign_key "submission_actions", "submissions", column: "submission_short_id", primary_key: "short_id"
  add_foreign_key "submission_actions", "users", on_delete: :cascade
  add_foreign_key "submission_removals", "submissions", on_delete: :cascade
  add_foreign_key "submission_removals", "users", column: "removed_by_id", on_delete: :cascade
  add_foreign_key "submission_tags", "submissions", on_delete: :cascade
  add_foreign_key "submission_tags", "tags", on_delete: :cascade
  add_foreign_key "submissions", "domains"
  add_foreign_key "submissions", "users"
  add_foreign_key "thread_reply_notifications", "comments", column: "in_response_to_comment_id", on_delete: :cascade
  add_foreign_key "thread_reply_notifications", "comments", column: "reply_id", on_delete: :cascade
  add_foreign_key "thread_reply_notifications", "users", column: "recipient_id", on_delete: :cascade
  add_foreign_key "user_invitations", "users", column: "recipient_id", on_delete: :cascade
  add_foreign_key "user_invitations", "users", column: "sender_id", on_delete: :cascade
  add_foreign_key "users", "users", column: "banned_by_id", on_delete: :cascade
  add_foreign_key "votes", "users", on_delete: :cascade

  create_view "flattened_thread_reply_notifications", sql_definition: <<-SQL
      SELECT thread_reply_notifications.id,
      thread_reply_notifications.recipient_id,
      thread_reply_notifications.dismissed,
      thread_reply_notifications.reply_id,
      replies.submission_id,
      submission_votes.kind AS submission_vote_kind,
      replies.short_id AS reply_short_id,
      replies.body AS reply_body,
      reply_votes.kind AS reply_vote_kind,
      replies.created_at AS reply_created_at,
      replies.updated_at AS reply_updated_at,
      (( SELECT count(votes.votable_id) AS count
             FROM votes
            WHERE (((votes.votable_type)::text = 'Comment'::text) AND (votes.votable_id = thread_reply_notifications.reply_id) AND (votes.kind = 0))) - ( SELECT count(votes.votable_id) AS count
             FROM votes
            WHERE (((votes.votable_type)::text = 'Comment'::text) AND (votes.votable_id = thread_reply_notifications.reply_id) AND (votes.kind = 1)))) AS reply_score,
      reply_users.username AS reply_commenter,
      thread_reply_notifications.in_response_to_comment_id AS irtc_id,
      irtcs.short_id AS irtc_short_id,
      irtcs.body AS irtc_body,
      irtc_votes.kind AS irtc_vote_kind,
      irtcs.created_at AS irtc_created_at,
      irtcs.updated_at AS irtc_updated_at,
      (( SELECT count(votes.votable_id) AS count
             FROM votes
            WHERE (((votes.votable_type)::text = 'Comment'::text) AND (votes.votable_id = thread_reply_notifications.in_response_to_comment_id) AND (votes.kind = 0))) - ( SELECT count(votes.votable_id) AS count
             FROM votes
            WHERE (((votes.votable_type)::text = 'Comment'::text) AND (votes.votable_id = thread_reply_notifications.in_response_to_comment_id) AND (votes.kind = 1)))) AS irtc_score
     FROM ((((((thread_reply_notifications
       JOIN comments replies ON ((replies.id = thread_reply_notifications.reply_id)))
       JOIN users reply_users ON ((reply_users.id = replies.user_id)))
       LEFT JOIN votes reply_votes ON (((reply_votes.user_id = thread_reply_notifications.recipient_id) AND ((reply_votes.votable_type)::text = 'Comment'::text) AND (reply_votes.votable_id = thread_reply_notifications.reply_id))))
       LEFT JOIN votes submission_votes ON (((submission_votes.user_id = thread_reply_notifications.recipient_id) AND ((submission_votes.votable_type)::text = 'Submission'::text) AND (submission_votes.votable_id = replies.submission_id))))
       JOIN comments irtcs ON ((irtcs.id = thread_reply_notifications.in_response_to_comment_id)))
       LEFT JOIN votes irtc_votes ON (((irtc_votes.user_id = thread_reply_notifications.recipient_id) AND ((irtc_votes.votable_type)::text = 'Comment'::text) AND (irtc_votes.votable_id = thread_reply_notifications.in_response_to_comment_id))))
    WHERE (thread_reply_notifications.in_response_to_comment_id IS NOT NULL)
  UNION ALL
   SELECT thread_reply_notifications.id,
      thread_reply_notifications.recipient_id,
      thread_reply_notifications.dismissed,
      thread_reply_notifications.reply_id,
      replies.submission_id,
      submission_votes.kind AS submission_vote_kind,
      replies.short_id AS reply_short_id,
      replies.body AS reply_body,
      reply_votes.kind AS reply_vote_kind,
      replies.created_at AS reply_created_at,
      replies.updated_at AS reply_updated_at,
      (( SELECT count(votes.votable_id) AS count
             FROM votes
            WHERE (((votes.votable_type)::text = 'Comment'::text) AND (votes.votable_id = thread_reply_notifications.reply_id) AND (votes.kind = 0))) - ( SELECT count(votes.votable_id) AS count
             FROM votes
            WHERE (((votes.votable_type)::text = 'Comment'::text) AND (votes.votable_id = thread_reply_notifications.reply_id) AND (votes.kind = 1)))) AS reply_score,
      reply_users.username AS reply_commenter,
      NULL::bigint AS irtc_id,
      NULL::character varying AS irtc_short_id,
      NULL::text AS irtc_body,
      NULL::integer AS irtc_vote_kind,
      NULL::timestamp without time zone AS irtc_created_at,
      NULL::timestamp without time zone AS irtc_updated_at,
      NULL::bigint AS irtc_score
     FROM ((((thread_reply_notifications
       JOIN comments replies ON ((replies.id = thread_reply_notifications.reply_id)))
       JOIN users reply_users ON ((reply_users.id = replies.user_id)))
       LEFT JOIN votes reply_votes ON (((reply_votes.user_id = thread_reply_notifications.recipient_id) AND ((reply_votes.votable_type)::text = 'Comment'::text) AND (reply_votes.votable_id = thread_reply_notifications.reply_id))))
       LEFT JOIN votes submission_votes ON (((submission_votes.user_id = thread_reply_notifications.recipient_id) AND ((submission_votes.votable_type)::text = 'Submission'::text) AND (submission_votes.votable_id = replies.submission_id))))
    WHERE (thread_reply_notifications.in_response_to_comment_id IS NULL);
  SQL
  create_view "flattened_submissions", sql_definition: <<-SQL
      SELECT submissions.id,
      submissions.short_id,
      submissions.removed,
      submissions.title,
      submissions.url,
      domains.name AS domain_name,
      NULL::text AS body,
      users.username AS submitter_username,
      submissions.original_author,
      submissions.created_at,
      submissions.user_id,
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
      submissions.removed,
      submissions.title,
      NULL::character varying AS url,
      NULL::character varying AS domain_name,
      submissions.body,
      users.username AS submitter_username,
      submissions.original_author,
      submissions.created_at,
      submissions.user_id,
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
      comments.removed,
      comments.submission_id,
      comments.parent_id,
      comments.body,
      comments.created_at,
      comments.updated_at,
      users.id AS user_id,
      users.username AS commenter,
      (( SELECT count(votes.votable_id) AS count
             FROM votes
            WHERE (((votes.votable_type)::text = 'Comment'::text) AND (votes.votable_id = comments.id) AND (votes.kind = 0))) - ( SELECT count(votes.votable_id) AS count
             FROM votes
            WHERE (((votes.votable_type)::text = 'Comment'::text) AND (votes.votable_id = comments.id) AND (votes.kind = 1)))) AS score
     FROM (comments
       JOIN users ON ((users.id = comments.user_id)));
  SQL
end
