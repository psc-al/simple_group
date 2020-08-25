module InboxItemHelper
  def subject_prefix_for(inbox_item)
    case inbox_item.item_type
    when "CommentReply"
      t(".comment_reply")
    when "SubmissionReply"
      t(".submission_reply")
    end
  end

  def subject_content_for(inbox_item)
    case inbox_item.item_type
    when "CommentReply", "SubmissionReply"
      link_to inbox_item.toplevel_subject, submission_comments_path(inbox_item.toplevel_short_id)
    else
      inbox_item.toplevel_subject
    end
  end

  def inbox_item_action_link(inbox_item)
    if inbox_item.read
      link_to t(".mark_as_unread"),
        inbox_item_path(inbox_item.id, inbox_item: { read: false }),
        method: :patch
    else
      link_to t(".mark_as_read"),
        inbox_item_path(inbox_item.id, inbox_item: { read: true }),
        method: :patch
    end
  end
end
