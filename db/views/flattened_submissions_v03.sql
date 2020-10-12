SELECT
  submissions.id, submissions.short_id, submissions.removed, title, url, domains.name AS domain_name,
  NULL AS body, users.username AS submitter_username, original_author, submissions.created_at,
  (
      SELECT COUNT(submission_id) AS comment_count
      FROM comments
      WHERE comments.submission_id = submissions.id
    ) AS comment_count,
  (
    (
      SELECT COUNT(votable_id)
      FROM votes
      WHERE votable_type = 'Submission'
      AND votable_id = submissions.id AND kind = 0
    ) -
    (
      SELECT COUNT(votable_id)
      FROM votes
      WHERE votable_type = 'Submission'
      AND votable_id = submissions.id AND kind = 1
    )
  ) AS score
FROM
  submissions
INNER JOIN users ON submissions.user_id = users.id
INNER JOIN domains ON submissions.domain_id = domains.id
WHERE submissions.domain_id IS NOT NULL

UNION ALL

SELECT
  submissions.id, submissions.short_id, submissions.removed, title, NULL AS url, NULL AS domain_name,
  submissions.body, users.username AS submitter_username, original_author, submissions.created_at,
  (
      SELECT COUNT(submission_id) AS comment_count
      FROM comments
      WHERE comments.submission_id = submissions.id
    ) AS comment_count,
  (
    (
      SELECT COUNT(votable_id)
      FROM votes
      WHERE votable_type = 'Submission'
      AND votable_id = submissions.id AND kind = 0
    ) -
    (
      SELECT COUNT(votable_id)
      FROM votes
      WHERE votable_type = 'Submission'
      AND votable_id = submissions.id AND kind = 1
    )
  ) AS score
FROM
  submissions
INNER JOIN users ON submissions.user_id = users.id
WHERE submissions.domain_id IS NULL
