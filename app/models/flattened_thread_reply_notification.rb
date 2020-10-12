class FlattenedThreadReplyNotification < ApplicationRecord
  self.primary_key = :id

  belongs_to :flattened_submission,
    class_name: :FlattenedSubmission,
    primary_key: :id,
    foreign_key: :submission_id
  belongs_to :recipient,
    class_name: :User,
    primary_key: :id

  scope :comment_replies, -> { where.not(irtc_id: nil) }
  scope :submission_replies, -> { where(irtc_id: nil) }
  scope :visible, lambda {
    where(
      Submission.
      where(removed: false).
      where("flattened_thread_reply_notifications.submission_id = submissions.id").arel.exists
    )
  }
end
