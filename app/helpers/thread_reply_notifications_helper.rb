module ThreadReplyNotificationsHelper
  def notification_action_link_text(notification)
    if notification.dismissed?
      t(".mark_as_unread")
    else
      t(".mark_as_read")
    end
  end

  def formatted_time_text(time)
    "#{time_ago_in_words(time)} #{t('submissions.submission_list_item.ago')}"
  end
end
