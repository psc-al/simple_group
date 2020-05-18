class CreateComments < ActiveRecord::Migration[6.0]
  def change
    adapter = ActiveRecord::Base.connection.adapter_name.downcase
    enable_extension "ltree" if adapter == "postgresql"
    create_table :comments do |t|
      t.string :short_id, null: false
      t.belongs_to :user, null: false, foreign_key: { on_delete: :cascade }
      t.belongs_to :submission, null: false, foreign_key: { on_delete: :cascade }
      # we're keeping the reference to parent to enforce some degree of foreign
      # key constraints. We don't want to end up with orphaned trees.
      t.belongs_to :parent, null: true,
        foreign_key: { to_table: :comments, on_delete: :cascade }
      t.text :body, null: false
      if adapter == "postgresql"
        # use LTREE extension for efficiently managing comment ancestry paths
        t.ltree :ancestry_path, null: true
      else
        # TODO: figure out if useful extensions exist for other dbms
        t.text :ancestry_path, null: true
      end

      t.timestamps
    end

    add_index :comments, :short_id, unique: true
    add_index :comments, :ancestry_path, using: :gist if adapter == "postgresql"
  end
end
