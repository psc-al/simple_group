class Submission < ApplicationRecord
  belongs_to :user
  belongs_to :domain, optional: true
end
