class AddRemovedToComments < ActiveRecord::Migration[6.0]
  def change
    add_column :comments, :removed, :boolean, null: false, default: false
    add_index :comments, :removed
  end
end
