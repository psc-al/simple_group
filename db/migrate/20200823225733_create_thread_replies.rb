class CreateThreadReplies < ActiveRecord::Migration[6.0]
  def change
    create_table :thread_replies do |t|
      t.belongs_to :user, null: false, foreign_key: { on_delete: :cascade }
      t.belongs_to :comment, null: false, foreign_key: { on_delete: :cascade }

      t.timestamps
    end
  end
end
