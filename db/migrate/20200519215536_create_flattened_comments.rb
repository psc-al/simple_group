class CreateFlattenedComments < ActiveRecord::Migration[6.0]
  def change
    create_view :flattened_comments
  end
end
