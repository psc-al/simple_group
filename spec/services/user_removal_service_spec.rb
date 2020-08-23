RSpec.describe UserRemovalService do
  describe "#remove" do
    it "scrubs the user data, sets their username / email to `[deleted]`, and changes status to deactivated" do
      user = create(:user)
      tag = create(:topic_tag)
      url_submission = create(:submission, :url, title: "foo title", url: "https://site.com", user: user, tags: [tag])
      text_submission = create(:submission, :text, title: "bar title", body: "abcdefghijklmn", user: user, tags: [tag])
      comment = create(:comment, user: user, body: "123456789")
      create(:user_invitation, :accepted, recipient: user)

      service = UserRemovalService.new(user)

      service.remove

      user.reload

      expect(user).to be_deactivated
      expect(user.email).to eq(User::DELETED)
      expect(user.unconfirmed_email).to eq(User::DELETED)
      expect(user.username).to eq(User::DELETED)
      expect(user.confirmation_token).to be_nil
      expect(user.confirmed_at).to be_nil
      expect(user.confirmation_sent_at).to be_nil
      expect(user.locked_at).to be_present

      url_submission.reload
      # we don't expect URL submissions to change
      expect(url_submission.title).to eq("foo title")
      expect(url_submission.url).to eq("https://site.com")

      text_submission.reload
      expect(text_submission.title).to eq("bar title")
      expect(text_submission.body).to eq(User::DELETED)

      comment.reload
      expect(comment.body).to eq(User::DELETED)

      expect(user.received_user_invitation.recipient_email).to eq(User::DELETED)
    end
  end
end
