class SubmissionTag < ApplicationRecord
  belongs_to :submission
  belongs_to :tag
end
