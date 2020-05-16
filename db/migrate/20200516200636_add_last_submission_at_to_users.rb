class AddLastSubmissionAtToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :last_submission_at, :datetime
  end
end
