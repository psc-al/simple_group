RSpec.describe "downvote submissions" do
  describe "PUT /api/v1/submissions/:submission_short_id/downvotes" do
    let(:submission) { create(:submission) }
    let(:user) { create(:user) }

    context "when the user is not logged in" do
      it "returns 403 forbidden" do
        put "/api/v1/submissions/#{submission.short_id}/downvotes"

        expect(response).to be_forbidden
      end
    end

    context "when the user hasn't commented directly on the submission" do
      it "returns 403 forbidden and error information" do
        login_as(user)

        # some comment in response to the comment being downvoted but not made
        # by our user
        direct_comment = create(:comment, submission: submission)
        # i.e. the user has responded to a comment in the tree, but not the comment itself
        # so they shouldn't be able to downvote. 
        user_response = create(
          :comment,
          parent: direct_comment,
          submission: submission,
          user: user
        )

        put "/api/v1/submissions/#{submission.short_id}/downvotes"

        body = JSON.parse(response.body).symbolize_keys

        expect(response).to be_forbidden
        expect(body).to eq({
          short_id: submission.short_id,
          action: "rejected",
          info: I18n.t("api.v1.submissions.downvotes.update.comment_before_downvote")
        })
      end
    end

    context "when no vote record exists for the user and submission" do
      it "creates a new downvote vote record for the user and submission and returns 200" do
        login_as(user)
        create(:comment, submission: submission, user: user)

        put "/api/v1/submissions/#{submission.short_id}/downvotes"

        body = JSON.parse(response.body).symbolize_keys

        expect(response).to be_ok
        expect(body).to eq({
          short_id: submission.short_id,
          action: "downvoted"
        })
        expect(Vote.count).to eq(1)

        vote = Vote.first

        expect(vote.user_id).to eq(user.id)
        expect(vote.votable_type).to eq("Submission")
        expect(vote.votable_id).to eq(submission.id)
      end
    end

    # this corresponds with the user clicking the downvote button twice, i.e. to remove
    # their vote.
    context "when a vote record exists for the user and submission and it's an downvote" do
      it "destroys it and returns a 200 status code" do
        login_as(user)
        create(:comment, submission: submission, user: user)
        create(:downvote, votable: submission, user: user)

        put "/api/v1/submissions/#{submission.short_id}/downvotes"

        body = JSON.parse(response.body).symbolize_keys

        expect(response).to be_ok
        expect(body).to eq({
          short_id: submission.short_id,
          action: "removed"
        })
        expect(Vote.count).to eq(0)
      end
    end

    context "when a vote record exists for the user and submission and it's a downvote" do
      it "turns it into an downvote and returns a 200 status code" do
        login_as(user)
        create(:comment, submission: submission, user: user)
        create(:upvote, votable: submission, user: user)

        put "/api/v1/submissions/#{submission.short_id}/downvotes"

        body = JSON.parse(response.body).symbolize_keys

        expect(response).to be_ok
        expect(body).to eq({
          short_id: submission.short_id,
          action: "downvoted"
        })
        expect(Vote.count).to eq(1)

        vote = Vote.first

        expect(vote.user_id).to eq(user.id)
        expect(vote.votable_type).to eq("Submission")
        expect(vote.votable_id).to eq(submission.id)
      end
    end
  end
end
