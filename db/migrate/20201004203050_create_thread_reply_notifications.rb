class CreateThreadReplyNotifications < ActiveRecord::Migration[6.0]
  def change
    create_table :thread_reply_notifications do |t|
      t.belongs_to :recipient, null: false, foreign_key: { to_table: :users, on_delete: :cascade }
      t.belongs_to :in_response_to_comment, null: true,
        index: false,
        foreign_key: { to_table: :comments, on_delete: :cascade }
      t.belongs_to :reply, null: false, foreign_key: { to_table: :comments, on_delete: :cascade }
      t.boolean :dismissed, null: false, default: false

      t.timestamps
    end

    add_index :thread_reply_notifications, :in_response_to_comment_id
    add_index :thread_reply_notifications, :dismissed
  end
end
