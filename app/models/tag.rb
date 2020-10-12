class Tag < ApplicationRecord
  ID_REGEX = /\A[a-z]+(-[a-z0-9]+|[a-z0-9])*\z/.freeze
  enum kind: {
    topic: 0,
    media: 5,
    source: 10,
    meta: 15,
    mod: 20
  }

  validate :validate_tag_id_format

  has_many :submission_tags
  has_many :submissions, through: :submission_tags

  def self.for_user(user)
    if user.moderator? || user.admin?
      Tag.all
    else
      Tag.where.not(kind: :mod)
    end
  end

  private

  def validate_tag_id_format
    unless id.match?(ID_REGEX)
      errors.add(:id, "ID must match format: #{ID_REGEX.inspect}")
    end
  end
end
