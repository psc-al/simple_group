RSpec.describe "downvote comments" do
  describe "PUT /api/v1/comments/:comment_short_id/downvotes" do
    let(:comment) { create(:comment) }
    let(:user) { create(:user) }

    context "when the user is not logged in" do
      it "returns 403 forbidden" do
        put "/api/v1/comments/#{comment.short_id}/downvotes"

        expect(response).to be_forbidden
      end
    end

    context "when the user hasn't directly responded to the comment being downvoted" do
      it "returns 403 forbidden and error information" do
        login_as(user)
        # some comment in response to the comment being downvoted but not made
        # by our user
        direct_comment = create(:comment, parent: comment, submission: comment.submission)
        # i.e. the user has responded to a comment in the tree, but not the comment itself
        # so they shouldn't be able to downvote.
        create(
          :comment,
          parent: direct_comment,
          submission: comment.submission,
          user: user
        )

        put "/api/v1/comments/#{comment.short_id}/downvotes"

        body = JSON.parse(response.body).symbolize_keys

        expect(response).to be_forbidden
        expect(body).to eq({
          short_id: comment.short_id,
          action: "rejected",
          info: I18n.t("api.v1.comments.downvotes.update.comment_before_downvote")
        })
      end
    end

    context "when the user authored the comment" do
      it "returns 200" do
        login_as(user)
        user_comment = create(:comment, user: user)

        put "/api/v1/comments/#{user_comment.short_id}/downvotes"

        body = JSON.parse(response.body).symbolize_keys

        expect(response).to be_ok
        expect(body).to eq({
          short_id: user_comment.short_id,
          action: "downvoted"
        })
        expect(Vote.count).to eq(1)

        vote = Vote.first

        expect(vote.user_id).to eq(user.id)
        expect(vote.votable_type).to eq("Comment")
        expect(vote.votable_id).to eq(user_comment.id)
      end
    end

    context "when no vote record exists for the user and comment" do
      it "creates a new downvote vote record for the user and comment and returns 200" do
        login_as(user)
        create(:comment, parent: comment, user: user)

        put "/api/v1/comments/#{comment.short_id}/downvotes"

        body = JSON.parse(response.body).symbolize_keys

        expect(response).to be_ok
        expect(body).to eq({
          short_id: comment.short_id,
          action: "downvoted"
        })
        expect(Vote.count).to eq(1)

        vote = Vote.first

        expect(vote.user_id).to eq(user.id)
        expect(vote.votable_type).to eq("Comment")
        expect(vote.votable_id).to eq(comment.id)
      end
    end

    # this corresponds with the user clicking the downvote button twice, i.e. to remove
    # their vote.
    context "when a vote record exists for the user and comment and it's an downvote" do
      it "destroys it and returns a 200 status code" do
        login_as(user)
        create(:comment, parent: comment, user: user)
        create(:downvote, votable: comment, user: user)

        put "/api/v1/comments/#{comment.short_id}/downvotes"

        body = JSON.parse(response.body).symbolize_keys

        expect(response).to be_ok
        expect(body).to eq({
          short_id: comment.short_id,
          action: "removed"
        })
        expect(Vote.count).to eq(0)
      end
    end

    context "when a vote record exists for the user and comment and it's a downvote" do
      it "turns it into an downvote and returns a 200 status code" do
        login_as(user)
        create(:comment, parent: comment, user: user)
        create(:upvote, votable: comment, user: user)

        put "/api/v1/comments/#{comment.short_id}/downvotes"

        body = JSON.parse(response.body).symbolize_keys

        expect(response).to be_ok
        expect(body).to eq({
          short_id: comment.short_id,
          action: "downvoted"
        })
        expect(Vote.count).to eq(1)

        vote = Vote.first

        expect(vote.user_id).to eq(user.id)
        expect(vote.votable_type).to eq("Comment")
        expect(vote.votable_id).to eq(comment.id)
      end
    end
  end
end
