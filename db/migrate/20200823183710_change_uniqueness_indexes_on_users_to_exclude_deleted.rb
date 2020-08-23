class ChangeUniquenessIndexesOnUsersToExcludeDeleted < ActiveRecord::Migration[6.0]
  def up
    remove_index :users, name: "index_users_on_LOWER_email"
    remove_index :users, name: "index_users_on_LOWER_username"

    add_index :users, "LOWER(email)", unique: true, name: "index_users_on_LOWER_email",
      where: "LOWER(email) != '[deleted]'"
    add_index :users, "LOWER(username)", unique: true, name: "index_users_on_LOWER_username",
      where: "LOWER(username) != '[deleted]'"
  end

  def down
    remove_index :users, name: "index_users_on_LOWER_email"
    remove_index :users, name: "index_users_on_LOWER_username"

    add_index :users, "LOWER(email)", unique: true, name: "index_users_on_LOWER_email"
    add_index :users, "LOWER(username)", unique: true, name: "index_users_on_LOWER_username"
  end
end
