class ThreadReply < ApplicationRecord
  belongs_to :user
  belongs_to :comment
end
