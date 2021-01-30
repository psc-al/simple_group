class CreateCommentRemovals < ActiveRecord::Migration[6.0]
  def change
    create_table :comment_removals do |t|
      t.belongs_to :comment, null: false, index: false, foreign_key: { on_delete: :cascade }
      t.belongs_to :removed_by, null: false, index: false,
        foreign_key: { on_delete: :cascade, to_table: :users }
      t.integer :reason, null: false
      t.text :details

      t.timestamps
    end

    add_index :comment_removals, :comment_id, unique: true
  end
end
