module Inbox
  class ThreadReplyNotificationsController < AuthenticatedController
    def index
      @filter_form = ThreadReplyNotificationFilterForm.new(filter_params)
      @notifications = filtered_notifications(@filter_form).includes(:flattened_submission)
    end

    def update
      notification = current_user.thread_reply_notifications.find(params[:id])
      notification.update!(dismissed: !notification.dismissed)
      i18n_prefix = "inbox.thread_reply_notifications.thread_reply_notification"

      text = if notification.dismissed?
               t("#{i18n_prefix}.mark_as_unread")
             else
               t("#{i18n_prefix}.mark_as_read")
             end

      render json: {
        text: text
      }
    end

    private

    def filtered_notifications(filter_form)
      if filter_form.dismissed
        filter_by_reply_type(current_user.flattened_thread_reply_notifications, filter_form)
      else
        filter_by_reply_type(current_user.flattened_thread_reply_notifications.where(dismissed: false), filter_form)
      end
    end

    def filter_by_reply_type(relation, filter_form)
      if filter_form.replies_to_comments && filter_form.replies_to_submissions
        relation
      elsif filter_form.replies_to_comments
        relation.comment_replies
      elsif filter_form.replies_to_submissions
        relation.submission_replies
      else
        relation.none
      end
    end

    def filter_params
      params.
        permit(thread_reply_notification_filter_form: [:replies_to_comments, :replies_to_submissions, :dismissed]).
        fetch(:thread_reply_notification_filter_form, {
          replies_to_comments: "1",
          replies_to_submissions: "1",
          dismissed: "0"
        })
    end
  end
end
