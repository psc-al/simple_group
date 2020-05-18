class Submission < ApplicationRecord
  include ShortId

  belongs_to :user
  belongs_to :domain, optional: true
  has_many :submission_tags
  has_many :tags, through: :submission_tags
  has_many :comments

  def self.short_id_prefix
    :s_
  end

  def self.left_join_saved_info_for(user)
    joins(left_join_submission_actions_sql(user, :saved))
  end

  def self.left_join_hidden_info_for(user)
    joins(left_join_submission_actions_sql(user, :hidden))
  end

  class << self
    private

    def left_join_submission_actions_sql(user, kind)
      tmp_table = "#{kind}_actions"
      %(
      LEFT JOIN
        submission_actions #{tmp_table}
      ON
        #{tmp_table}.user_id = #{user.id}
      AND
        #{tmp_table}.kind = #{SubmissionAction.kinds[kind]}
      AND
        #{tmp_table}.submission_short_id = submissions.short_id
      ).squish
    end
  end
end
