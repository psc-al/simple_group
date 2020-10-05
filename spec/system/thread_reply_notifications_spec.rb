RSpec.describe "Thread reply notifications", js: true do
  let(:user) { create(:user) }
  let(:page) { ThreadReplyNotificationsPage.new }

  context "when a user goes to their thread replies inbox" do
    it "can filter the notifications" do
      submission_reply = create(:thread_reply_notification, recipient: user)
      dismissed_submission_reply = create(:thread_reply_notification, recipient: user, dismissed: true)
      irtc = create(:comment, user: user)
      comment_reply = create(:thread_reply_notification, recipient: user, in_response_to_comment: irtc)

      page.visit(as: user)

      expect(page).to have_notification_row(submission_reply)
      expect(page).not_to have_notification_row(dismissed_submission_reply)
      expect(page).to have_notification_row(comment_reply)

      page.uncheck_filter_by_comment_replies

      expect(page).to have_notification_row(submission_reply)
      expect(page).not_to have_notification_row(dismissed_submission_reply)
      expect(page).not_to have_notification_row(comment_reply)

      page.uncheck_filter_by_submission_replies

      expect(page).not_to have_notification_row(submission_reply)
      expect(page).not_to have_notification_row(dismissed_submission_reply)
      expect(page).not_to have_notification_row(comment_reply)

      page.check_filter_by_submission_replies.include_read

      expect(page).to have_notification_row(submission_reply)
      expect(page).to have_notification_row(dismissed_submission_reply)
      expect(page).not_to have_notification_row(comment_reply)
    end

    it "can mark notifications as read / unread" do
      submission_reply = create(:thread_reply_notification, recipient: user)

      page.visit(as: user)

      expect(page).to have_notification_row(submission_reply)
      expect(page).to have_mark_as_read(submission_reply)

      page.mark_as_read(submission_reply)

      expect(page).to have_mark_as_unread(submission_reply)
      expect(submission_reply.reload).to be_dismissed

      page.include_read.mark_as_unread(submission_reply)

      expect(page).to have_mark_as_read(submission_reply)
      expect(submission_reply.reload).not_to be_dismissed
    end

    it "can upvote / downvote & reply to replies" do
      submission_reply = create(:thread_reply_notification, recipient: user)

      page.visit(as: user)

      expect(page).to have_notification_row(submission_reply)

      page.reply_to_thread_reply(submission_reply, body: "a reply")

      # one for the initial thread reply, one for our reply
      expect(Comment.count).to eq(2)

      comment = Comment.find_by(parent_id: submission_reply.reply_id)

      expect(comment.body).to eq("a reply")

      page.upvote_comment(submission_reply.reply)

      expect(page).to have_upvoted_comment(submission_reply.reply)
      expect(user.votes.upvote.where(votable: submission_reply.reply)).to exist

      page.downvote_comment(submission_reply.reply)

      expect(page).to have_downvoted_comment(submission_reply.reply)
      expect(user.votes.downvote.where(votable: submission_reply.reply)).to exist
    end
  end
end
