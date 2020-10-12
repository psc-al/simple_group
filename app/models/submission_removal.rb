class SubmissionRemoval < ApplicationRecord
  belongs_to :submission
  belongs_to :removed_by, class_name: :User

  enum reason: {
    off_topic: 0,
    spam: 1,
    doxxing: 666
  }
end
