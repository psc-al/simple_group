class CreateSubmissionActions < ActiveRecord::Migration[6.0]
  def change
    create_table :submission_actions do |t|
      t.belongs_to :user, null: false, index: false, foreign_key: { on_delete: :cascade }
      t.string :submission_short_id, null: false
      t.integer :kind, null: false

      t.timestamps
    end

    add_foreign_key :submission_actions, :submissions,
      column: :submission_short_id, primary_key: :short_id
    add_index :submission_actions, [:user_id, :kind, :submission_short_id], unique: true,
      name: "idx_unique_submission_actions"
    add_index :submission_actions, :submission_short_id
    add_index :submission_actions, :kind
  end
end
