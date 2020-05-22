RSpec.describe "user votes on comment", js: true do
  let(:comment) { create(:comment) }
  let(:user) { create(:user) }
  let(:page) { ViewSubmissionPage.new }

  context "when the user upvotes the comment" do
    it "creates a new upvote record for the user + comment and styles the upvote button" do
      page.visit(comment.submission, as: user).upvote_comment(comment)

      expect(page).to have_upvoted_comment(comment)

      vote = Vote.preload(:votable).first

      expect(Vote.count).to eq(1)
      expect(vote).to be_upvote
      expect(vote.votable).to eq(comment)
      expect(vote.user_id).to eq(user.id)
    end
  end

  context "when the user tries to vote in quick succession" do
    it "throttles them and doesn't let the second vote request go through" do
      # unfortunately I don't really know of a much better way to test this
      # than to chain the calls together so that they fire in rapid succession
      page.
        visit(comment.submission, as: user).
        upvote_comment(comment).
        upvote_comment(comment)

      expect(page).to have_upvoted_comment(comment)

      vote = Vote.preload(:votable).first

      expect(Vote.count).to eq(1)
      expect(vote).to be_upvote
      expect(vote.votable).to eq(comment)
      expect(vote.user_id).to eq(user.id)
    end
  end

  context "when the user downvotes a comment" do
    it "creates a new downvote record for the user + comment and styles the downvote button" do
      create(:comment, user: user, parent: comment, submission: comment.submission)
      page.visit(comment.submission, as: user).downvote_comment(comment)

      expect(page).to have_downvoted_comment(comment)

      vote = Vote.preload(:votable).first

      expect(Vote.count).to eq(1)
      expect(vote).to be_downvote
      expect(vote.votable).to eq(comment)
      expect(vote.user_id).to eq(user.id)
    end
  end

  context "when the user tries to downvote a comment that they haven't replied to" do
    it "does not let them and shows an alert message" do
      page.visit(comment.submission, as: user).downvote_comment(comment)

      expect(page).not_to have_downvoted_comment(comment)
      expect(Vote.count).to eq(0)
      expect(page).to have_alert(I18n.t("api.v1.comments.downvotes.update.comment_before_downvote"))
    end
  end
end
