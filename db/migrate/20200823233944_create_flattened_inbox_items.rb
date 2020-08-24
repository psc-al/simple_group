class CreateFlattenedInboxItems < ActiveRecord::Migration[6.0]
  def change
    create_view :flattened_inbox_items
  end
end
