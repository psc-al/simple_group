class Tag < ApplicationRecord
  enum kind: {
    topic: 0,
    media: 5,
    source: 10,
    meta: 15,
    mod: 20
  }

  has_many :submission_tags
  has_many :submissions, through: :submission_tags

  def self.for_user(user)
    if user.moderator? || user.admin?
      Tag.all
    else
      Tag.where.not(kind: :mod)
    end
  end
end
