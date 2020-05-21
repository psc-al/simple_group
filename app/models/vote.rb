# frozen_string_literal: true

class Vote < ApplicationRecord
  belongs_to :votable, polymorphic: true
  belongs_to :user
  validate :supported_votable_type

  enum kind: {
    upvote: 0,
    downvote: 1
  }

  SUPPORTED_VOTABLE_TYPES = [Submission, Comment].freeze

  private

  def supported_votable_type
    unless SUPPORTED_VOTABLE_TYPES.include?(votable_type.constantize)
      errors.add(
        :votable_type,
        I18n.t("votes.errors.unsupported_votable_type", type: votable_type.pluralize.downcase)
      )
    end
  end
end
