class CreateFlattenedThreadReplyNotifications < ActiveRecord::Migration[6.0]
  def change
    create_view :flattened_thread_reply_notifications
  end
end
