class AddRemovedToSubmissions < ActiveRecord::Migration[6.0]
  def change
    add_column :submissions, :removed, :boolean, null: false, default: false
    add_index :submissions, :removed
  end
end
