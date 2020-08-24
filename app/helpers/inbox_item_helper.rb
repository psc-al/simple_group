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
end
