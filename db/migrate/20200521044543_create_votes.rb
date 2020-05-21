class CreateVotes < ActiveRecord::Migration[6.0]
  def change
    create_table :votes do |t|
      t.belongs_to :votable, null: false, index: false, polymorphic: true
      t.belongs_to :user, null: false, index: false, foreign_key: { on_delete: :cascade }
      t.integer :kind, null: false
      t.integer :downvote_reason

      t.timestamps
    end

    add_index :votes, [:user_id, :votable_type, :votable_id, :kind], unique: true,
      name: "idx_uniq_votes_user_votable_and_kind"
    add_index :votes, [:votable_type, :votable_id, :kind]
  end
end
