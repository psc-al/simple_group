# frozen_string_literal: true

class Vote < ApplicationRecord
  belongs_to :votable, polymorphic: true
  belongs_to :user
  validate :supported_votable_type
  validates :downvote_reason,
    absence: { message: I18n.t("votes.errors.downvote_reason_for_upvote") },
    if: ->(v) { v.upvote? }
  validates :downvote_reason,
    presence: { message: I18n.t("votes.errors.missing_downvote_reason") },
    if: ->(v) { v.downvote? }
  validate :valid_downvote_reason,
    if: ->(v) { v.downvote? && v.downvote_reason.present? }

  enum kind: {
    upvote: 0,
    downvote: 1
  }

  enum downvote_reason: {
    off_topic: 0,
    incorrect: 5,
    spam: 10,
    mean: 15,
    unhelpful: 20,
    troll: 25,
    broken_link: 30,
    repost: 35
  }

  SUBMISSION_DOWNVOTE_REASONS = %i[off_topic incorrect spam troll broken_link repost].freeze
  COMMENT_DOWNVOTE_REASONS = %i[off_topic incorrect spam mean unhelpful troll].freeze
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

  def valid_downvote_reason
    case votable
    when Submission
      validate_submission_downvote_reason
    when Comment
      validate_comment_downvote_reason
    end
  end

  def validate_submission_downvote_reason
    unless SUBMISSION_DOWNVOTE_REASONS.include?(downvote_reason.to_sym)
      errors.add(:downvote_reason, I18n.t("votes.errors.invalid_submission_downvote_reason"))
    end
  end

  def validate_comment_downvote_reason
    unless COMMENT_DOWNVOTE_REASONS.include?(downvote_reason.to_sym)
      errors.add(:downvote_reason, I18n.t("votes.errors.invalid_comment_downvote_reason"))
    end
  end
end
