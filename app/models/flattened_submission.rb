# frozen_string_literal: true

class FlattenedSubmission < ApplicationRecord
  extend FriendlyId

  has_many :submission_tags, primary_key: :id, foreign_key: :submission_id
  has_many :tags, through: :submission_tags
  has_many :flattened_comments, -> { order(:parent_id) },
    class_name: "FlattenedComment",
    primary_key: :id,
    foreign_key: :submission_id

  self.primary_key = :id

  friendly_id :short_id

  def self.left_join_saved_info_for(user)
    joins(with_submission_actions_sql(user, :saved))
  end

  def self.left_join_hidden_info_for(user)
    joins(with_submission_actions_sql(user, :hidden))
  end

  def self.with_voting_information_for(user)
    if user.present?
      joins(
        %(
        LEFT JOIN
          votes
        ON
          votes.user_id = #{user.id}
        AND
          votes.votable_type = 'Submission'
        AND
          votes.votable_id = flattened_submissions.id
      ).squish
      ).select("flattened_submissions.*, votes.kind AS vote_kind")
    else
      select("flattened_submissions.*, NULL AS vote_kind")
    end
  end

  class << self
    private

    def with_submission_actions_sql(user, kind)
      tmp_table = "#{kind}_actions"
      %(
      LEFT JOIN
        submission_actions #{tmp_table}
      ON
        #{tmp_table}.user_id = #{user.id}
      AND
        #{tmp_table}.kind = #{SubmissionAction.kinds[kind]}
      AND
        #{tmp_table}.submission_short_id = flattened_submissions.short_id
      ).squish
    end
  end
end
