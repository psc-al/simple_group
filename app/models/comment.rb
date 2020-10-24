class Comment < ApplicationRecord
  include ShortId
  include Comments::TreeMethods

  belongs_to :user
  belongs_to :submission
  belongs_to :parent, optional: true, class_name: "Comment"
  has_many :votes, as: :votable
  has_one :comment_removal, required: false

  scope :visible, -> { where(removed: false) }

  validates :body, presence: true

  def self.short_id_prefix
    :c_
  end
end
