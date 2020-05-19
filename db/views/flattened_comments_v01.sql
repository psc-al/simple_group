SELECT
  id, short_id, submission_id, parent_id,
  body, comments.created_at, comments.updated_at,
  users.username AS commenter
FROM comments
INNER JOIN users ON users.id = comments.user_id
