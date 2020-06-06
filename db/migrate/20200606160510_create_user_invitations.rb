class CreateUserInvitations < ActiveRecord::Migration[6.0]
  def change
    create_table :user_invitations do |t|
      t.belongs_to :sender, null: false, foreign_key: { to_table: :users, on_delete: :cascade }
      t.string :recipient_email, null: false
      t.belongs_to :recipient, null: true, foreign_key: { to_table: :users, on_delete: :cascade }
      t.datetime :sent_at
      t.datetime :accepted_at
      t.string :token, null: false

      t.timestamps
    end

    add_index :user_invitations, :recipient_email, unique: true
    add_index :user_invitations, :token, unique: true
  end
end
