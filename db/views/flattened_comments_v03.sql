SELECT
  comments.id, comments.short_id, comments.removed,
  submission_id, parent_id, body, comments.created_at,
  comments.updated_at, users.id AS user_id,
  users.username AS commenter,
  (
    (
      SELECT COUNT(votable_id)
      FROM votes
      WHERE votable_type = 'Comment'
      AND votable_id = comments.id AND kind = 0
    ) - 
    (
      SELECT COUNT(votable_id)
      FROM votes
      WHERE votable_type = 'Comment'
      AND votable_id = comments.id AND kind = 1
    ) 
  ) AS score
FROM comments
INNER JOIN users ON users.id = comments.user_id
