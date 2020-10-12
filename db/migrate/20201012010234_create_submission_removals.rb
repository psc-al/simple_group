class CreateSubmissionRemovals < ActiveRecord::Migration[6.0]
  def change
    create_table :submission_removals do |t|
      t.belongs_to :submission, null: false, index: false, foreign_key: { on_delete: :cascade }
      t.belongs_to :removed_by, null: false, index: false, foreign_key: { to_table: :users, on_delete: :cascade }
      t.integer :reason, null: false
      t.text :details

      t.timestamps
    end

    add_index :submission_removals, :submission_id, unique: true
  end
end
