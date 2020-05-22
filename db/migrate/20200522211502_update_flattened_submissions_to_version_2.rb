class UpdateFlattenedSubmissionsToVersion2 < ActiveRecord::Migration[6.0]
  def change
    update_view :flattened_submissions, version: 2, revert_to_version: 1
  end
end
