class CommentRemoval < ApplicationRecord
  belongs_to :comment
  belongs_to :removed_by, class_name: "User"

  enum reason: {
    off_topic: 0,
    spam: 1,
    griefing: 2,
    doxxing: 666
  }
end
