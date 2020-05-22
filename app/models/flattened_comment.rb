class FlattenedComment < ApplicationRecord
  self.primary_key = :id

  def self.with_voting_information_for(user)
    if user.present?
      joins(
        %(
        LEFT JOIN
          votes
        ON
          votes.user_id = #{user.id}
        AND
          votes.votable_type = 'Comment'
        AND
          votes.votable_id = flattened_comments.id
      ).squish
      ).select("flattened_comments.*, votes.kind AS vote_kind")
    else
      select("flattened_comments.*, NULL AS vote_kind")
    end
  end
end
