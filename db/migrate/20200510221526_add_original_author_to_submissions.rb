class AddOriginalAuthorToSubmissions < ActiveRecord::Migration[6.0]
  def change
    add_column :submissions, :original_author, :boolean, null: false, default: false
  end
end
