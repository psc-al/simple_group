class AddCaseInsensitiveIndexesToUsernameAndEmailOnUsers < ActiveRecord::Migration[6.0]
  def up
    remove_index :users, :email
    remove_index :users, :username

    add_index :users, "LOWER(email)", unique: true, name: "index_users_on_LOWER_email"
    add_index :users, "LOWER(username)", unique: true, name: "index_users_on_LOWER_username"
  end

  def down
    remove_index :users, name: "index_users_on_LOWER_email"
    remove_index :users, name: "index_users_on_LOWER_username"

    add_index :users, :email, unique: true
    add_index :users, :username, unique: true
  end
end
