class CreateFlattenedSubmissions < ActiveRecord::Migration[6.0]
  def change
    create_view :flattened_submissions
  end
end
