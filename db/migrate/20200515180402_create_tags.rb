class CreateTags < ActiveRecord::Migration[6.0]
  def change
    create_table :tags, id: :string do |t|
      t.string :description, limit: 100
      t.integer :kind, null: false, default: 0

      t.timestamps
    end
  end
end
