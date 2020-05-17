class SubmissionAction < ApplicationRecord
  enum kind: {
    hidden: 0,
    saved: 1
  }

  belongs_to :submission, foreign_key: :submission_short_id, primary_key: :short_id
  belongs_to :user
end
