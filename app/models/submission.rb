class Submission < ApplicationRecord
  include ShortId

  belongs_to :user
  belongs_to :domain, optional: true
end
