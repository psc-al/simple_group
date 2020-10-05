SELECT
  thread_reply_notifications.id, recipient_id, dismissed,
  reply_id, replies.submission_id, submission_votes.kind AS submission_vote_kind,
  replies.short_id AS reply_short_id, replies.body AS reply_body,
  reply_votes.kind AS reply_vote_kind, replies.created_at AS reply_created_at,
  replies.updated_at AS reply_updated_at,
  (
    (
      SELECT COUNT(votable_id)
      FROM votes
      WHERE votable_type = 'Comment'
      AND votable_id = reply_id AND kind = 0
    ) -
    (
      SELECT COUNT(votable_id)
      FROM votes
      WHERE votable_type = 'Comment'
      AND votable_id = reply_id AND kind = 1
    )
  ) AS reply_score,
  reply_users.username AS reply_commenter,
  in_response_to_comment_id AS irtc_id, irtcs.short_id AS irtc_short_id,
  irtcs.body AS irtc_body, irtc_votes.kind AS irtc_vote_kind,
  irtcs.created_at AS irtc_created_at, irtcs.updated_at AS irtc_updated_at,
  (
    (
      SELECT COUNT(votable_id)
      FROM votes
      WHERE votable_type = 'Comment'
      AND votable_id = in_response_to_comment_id AND kind = 0
    ) -
    (
      SELECT COUNT(votable_id)
      FROM votes
      WHERE votable_type = 'Comment'
      AND votable_id = in_response_to_comment_id AND kind = 1
    )
  ) AS irtc_score
FROM thread_reply_notifications
INNER JOIN
  comments replies ON replies.id = thread_reply_notifications.reply_id
INNER JOIN
  users reply_users ON reply_users.id = replies.user_id
LEFT JOIN
  votes reply_votes
ON
  reply_votes.user_id = thread_reply_notifications.recipient_id
AND
  reply_votes.votable_type = 'Comment'
AND
  reply_votes.votable_id = thread_reply_notifications.reply_id
LEFT JOIN
  votes submission_votes
ON
  submission_votes.user_id = thread_reply_notifications.recipient_id
AND
  submission_votes.votable_type = 'Submission'
AND
  submission_votes.votable_id = replies.submission_id
INNER JOIN
  comments irtcs ON irtcs.id = thread_reply_notifications.in_response_to_comment_id
LEFT JOIN
  votes irtc_votes
ON
  irtc_votes.user_id = thread_reply_notifications.recipient_id
AND
  irtc_votes.votable_type = 'Comment'
AND
  irtc_votes.votable_id = thread_reply_notifications.in_response_to_comment_id
WHERE in_response_to_comment_id IS NOT NULL

UNION ALL

SELECT
  thread_reply_notifications.id, recipient_id, dismissed,
  reply_id, replies.submission_id, submission_votes.kind AS submission_vote_kind,
  replies.short_id AS reply_short_id,
  replies.body AS reply_body, reply_votes.kind AS reply_vote_kind,
  replies.created_at AS reply_created_at, replies.updated_at AS reply_updated_at,
  (
    (
      SELECT COUNT(votable_id)
      FROM votes
      WHERE votable_type = 'Comment'
      AND votable_id = reply_id AND kind = 0
    ) -
    (
      SELECT COUNT(votable_id)
      FROM votes
      WHERE votable_type = 'Comment'
      AND votable_id = reply_id AND kind = 1
    )
  ) AS reply_score,
  reply_users.username AS reply_commenter,
  NULL AS irtc_id, NULL AS irtc_short_id, NULL AS irtc_body, NULL AS irtc_vote_kind,
  NULL AS irtc_created_at, NULL AS irtc_updated_at, NULL AS irtc_score
FROM thread_reply_notifications
INNER JOIN
  comments replies ON replies.id = thread_reply_notifications.reply_id
INNER JOIN
  users reply_users ON reply_users.id = replies.user_id
LEFT JOIN
  votes reply_votes
ON
  reply_votes.user_id = thread_reply_notifications.recipient_id
AND
  reply_votes.votable_type = 'Comment'
AND
  reply_votes.votable_id = thread_reply_notifications.reply_id
LEFT JOIN
  votes submission_votes
ON
  submission_votes.user_id = thread_reply_notifications.recipient_id
AND
  submission_votes.votable_type = 'Submission'
AND
  submission_votes.votable_id = replies.submission_id
WHERE in_response_to_comment_id IS NULL
