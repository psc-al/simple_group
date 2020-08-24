/*
- toplevel_subject - subject of text of entity that inbox item was derived from (submission title, message subject, etc.)
- toplevel_type - type of toplevel entity that the inbox item falls under (Submission, MessageTree, etc.)
- toplevel_short_id - short id of the toplevel entity that the inbox item falls under
- user_id - id of the user that the inbox item belongs to
- actor_username - username of user who triggered the inbox item to be created
- item_type - type of entity that the inbox item relates to (Comment, Submission, etc.)
- item_short_id - short_id of the entity that the inbox item relates to
- item_body - body text of the entity that the inbox item relates to
*/

/* Comment replies */
SELECT
  submissions.title AS toplevel_subject,
  'Submission' AS toplevel_type,
  submissions.short_id AS toplevel_short_id,
  inbox_items.user_id AS user_id,
  users.username AS actor_username,
  'CommentReply' AS item_type,
  comments.short_id AS item_short_id,
  comments.body AS item_body,
  inbox_items.read,
  thread_replies.created_at AS inboxed_at
FROM
  inbox_items
INNER JOIN
  thread_replies ON inbox_items.inboxable_type = 'ThreadReply' AND inbox_items.inboxable_id = thread_replies.id
INNER JOIN
  comments ON thread_replies.comment_id = comments.id
INNER JOIN
  submissions ON comments.submission_id = submissions.id
INNER JOIN
  users ON comments.user_id = users.id
WHERE
  comments.parent_id IS NOT NULL

UNION ALL

/* Submission replies */
SELECT
  submissions.title AS toplevel_subject,
  'Submission' AS toplevel_type,
  submissions.short_id AS toplevel_short_id,
  inbox_items.user_id AS user_id,
  users.username AS actor_username,
  'SubmissionReply' AS item_type,
  comments.short_id AS item_short_id,
  comments.body AS item_body,
  inbox_items.read,
  thread_replies.created_at AS inboxed_at
FROM
  inbox_items
INNER JOIN
  thread_replies ON inbox_items.inboxable_type = 'ThreadReply' AND inbox_items.inboxable_id = thread_replies.id
INNER JOIN
  comments ON thread_replies.comment_id = comments.id
INNER JOIN
  submissions ON comments.submission_id = submissions.id
INNER JOIN
  users ON comments.user_id = users.id
WHERE
  comments.parent_id IS NULL
