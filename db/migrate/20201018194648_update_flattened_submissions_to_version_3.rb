class UpdateFlattenedSubmissionsToVersion3 < ActiveRecord::Migration[6.0]
  def change
    update_view :flattened_submissions, version: 3, revert_to_version: 2
  end
end
