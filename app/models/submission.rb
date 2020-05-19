class Submission < ApplicationRecord
  include ShortId

  belongs_to :user
  belongs_to :domain, optional: true
  has_many :submission_tags
  has_many :tags, through: :submission_tags
  has_many :comments
  has_many :root_comments, -> { where(parent_id: nil) }, class_name: "Comment"

  def self.short_id_prefix
    :s_
  end
end
