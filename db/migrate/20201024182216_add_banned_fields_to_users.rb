class AddBannedFieldsToUsers < ActiveRecord::Migration[6.0]
  def change
    change_table :users, bulk: true do |t|
      t.references :banned_by, foreign_key: { on_delete: :cascade, to_table: :users }
      t.column :banned_at, :datetime
      t.column :ban_type, :integer
      t.column :ban_reason, :text
      t.column :temp_ban_end_at, :datetime
      t.column :unbanned_at, :datetime
    end
  end
end
