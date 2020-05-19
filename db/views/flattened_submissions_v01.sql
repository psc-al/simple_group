SELECT
  submissions.id, submissions.short_id, title, url, domains.name AS domain_name,
  NULL AS body, users.username AS submitter_username, original_author, submissions.created_at,
  COALESCE(
    (
      SELECT COUNT(submission_id) AS comment_count
      FROM comments
      WHERE comments.submission_id = submissions.id
      GROUP BY submission_id
    ), 0) AS comment_count
FROM
  submissions
INNER JOIN users ON submissions.user_id = users.id
INNER JOIN domains ON submissions.domain_id = domains.id
WHERE submissions.domain_id IS NOT NULL

UNION ALL

SELECT
  submissions.id, submissions.short_id, title, NULL AS url, NULL AS domain_name,
  submissions.body, users.username AS submitter_username, original_author, submissions.created_at,
  COALESCE(
    (
      SELECT COUNT(submission_id) AS comment_count
      FROM comments
      WHERE comments.submission_id = submissions.id
      GROUP BY submission_id
    ), 0) AS comment_count
FROM
  submissions
INNER JOIN users ON submissions.user_id = users.id
WHERE submissions.domain_ID IS NULL
