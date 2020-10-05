class ThreadReplyNotification < ApplicationRecord
  belongs_to :recipient, class_name: :User
  belongs_to :in_response_to_comment, class_name: :Comment, optional: true
  belongs_to :reply, class_name: :Comment

  scope :comment_replies, -> { where.not(in_response_to_comment: nil) }
  scope :submission_replies, -> { where(in_response_to_comment: nil) }
  scope :unread, -> { where(dismissed: false) }
  scope :dismissed, -> { where(dismissed: true) }
end
