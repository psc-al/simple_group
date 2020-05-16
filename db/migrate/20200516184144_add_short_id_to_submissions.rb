class AddShortIdToSubmissions < ActiveRecord::Migration[6.0]
  def change
    add_column :submissions, :short_id, :string, null: false
    add_index :submissions, :short_id, unique: true
  end
end
