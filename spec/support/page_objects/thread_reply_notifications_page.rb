require "support/page_objects/page_base"

class ThreadReplyNotificationsPage < PageBase
  def visit(as:)
    login_as(as)
    super(inbox_path)
    self
  end

  def uncheck_filter_by_comment_replies
    uncheck :thread_reply_notification_filter_form_replies_to_comments
    self
  end

  def check_filter_by_submission_replies
    check :thread_reply_notification_filter_form_replies_to_submissions
    self
  end

  def uncheck_filter_by_submission_replies
    uncheck :thread_reply_notification_filter_form_replies_to_submissions
    self
  end

  def include_read
    check :thread_reply_notification_filter_form_dismissed
    self
  end

  def mark_as_read(notification)
    within find("#thread-reply-notification-#{notification.id}") do
      click_on "Mark as read"
    end
    self
  end

  def mark_as_unread(notification)
    within find("#thread-reply-notification-#{notification.id}") do
      click_on "Mark as unread"
    end
    self
  end

  def reply_to_thread_reply(notification, body:)
    within find("#thread-reply-notification-#{notification.id}") do
      click_on "reply"
      fill_in :comment_body, with: body
      click_on "Comment"
    end
    self
  end

  def upvote_comment(comment)
    vote_on_comment(comment, :up)
  end

  def downvote_comment(comment)
    vote_on_comment(comment, :down)
  end

  def has_notification_row?(notification)
    has_css?("#thread-reply-notification-#{notification.id}", wait: 0)
  end

  def has_mark_as_read?(notification)
    within find("#thread-reply-notification-#{notification.id}") do
      has_link? "Mark as read"
    end
  end

  def has_mark_as_unread?(notification)
    within find("#thread-reply-notification-#{notification.id}") do
      has_link? "Mark as unread"
    end
  end

  def has_upvoted_comment?(comment)
    has_comment_vote?(comment, :up)
  end

  def has_downvoted_comment?(comment)
    has_comment_vote?(comment, :down)
  end

  private

  def vote_on_comment(comment, direction)
    find("##{direction}vote_#{comment.short_id}").click
    self
  end

  def has_comment_vote?(comment, direction)
    within find("##{comment.short_id}") do
      has_css?(".#{direction}voted", wait: 1.5)
    end
  end
end
