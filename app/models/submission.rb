class Submission < ApplicationRecord
  include ShortId

  belongs_to :user
  belongs_to :domain, optional: true
  has_many :submission_tags
  has_many :tags, through: :submission_tags
end
