class CreateDomains < ActiveRecord::Migration[6.0]
  def change
    create_table :domains do |t|
      t.string :name, null: false
      t.boolean :tracker, null: false, default: false
      t.datetime :banned_at
      t.belongs_to :banned_by, null: true, index: false, foreign_key: { to_table: :users }

      t.timestamps
    end

    add_index :domains, :name, unique: true
    add_index :domains, :banned_by_id, where: "banned_by_id IS NOT NULL"
  end
end
