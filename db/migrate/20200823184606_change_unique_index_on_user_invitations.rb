class ChangeUniqueIndexOnUserInvitations < ActiveRecord::Migration[6.0]
  def up
    remove_index :user_invitations, :recipient_email
    add_index :user_invitations, "LOWER(recipient_email)",
      unique: true, name: "index_user_invitations_on_LOWER_recipient_email",
      where: "LOWER(recipient_email) != '[deleted]'"
  end

  def down
    remove_index :user_invitations, name: "index_user_invitations_on_LOWER_recipient_email"
    add_index :user_invitations, :recipient_email, unique: true
  end
end
