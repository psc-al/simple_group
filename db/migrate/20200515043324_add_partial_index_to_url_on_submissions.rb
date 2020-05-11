class AddPartialIndexToUrlOnSubmissions < ActiveRecord::Migration[6.0]
  def change
    add_index :submissions, :url, unique: true, where: "url IS NOT NULL"
  end
end
