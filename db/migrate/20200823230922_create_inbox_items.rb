class CreateInboxItems < ActiveRecord::Migration[6.0]
  def change
    create_table :inbox_items do |t|
      t.belongs_to :user, null: false, index: false, foreign_key: { on_delete: :cascade }
      t.belongs_to :inboxable, null: false, polymorphic: true
      t.boolean :read, null: false, default: false

      t.timestamps
    end

    add_index :inbox_items, [:user_id, :read]
  end
end
