class CreateSubmissionTags < ActiveRecord::Migration[6.0]
  def change
    create_table :submission_tags do |t|
      t.belongs_to :submission, null: false, foreign_key: { on_delete: :cascade }
      t.belongs_to :tag, null: false, type: :text, foreign_key: { on_delete: :cascade }

      t.timestamps
    end
  end
end
