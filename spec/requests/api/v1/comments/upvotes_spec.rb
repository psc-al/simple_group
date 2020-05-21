RSpec.describe "upvote comments" do
  describe "PUT /api/v1/comments/:comment_short_id/upvotes" do
    let(:comment) { create(:comment) }
    let(:user) { create(:user) }

    context "when the user is not logged in" do
      it "returns 403 forbidden" do
        put "/api/v1/comments/#{comment.short_id}/upvotes"

        expect(response).to be_forbidden
      end
    end

    context "when no vote record exists for the user and comment" do
      it "creates a new upvote vote record for the user and comment and returns 200" do
        login_as(user)

        put "/api/v1/comments/#{comment.short_id}/upvotes"

        body = JSON.parse(response.body).symbolize_keys

        expect(response).to be_ok
        expect(body).to eq({
          short_id: comment.short_id,
          action: "upvoted"
        })
        expect(Vote.count).to eq(1)

        vote = Vote.first

        expect(vote.user_id).to eq(user.id)
        expect(vote.votable_type).to eq("Comment")
        expect(vote.votable_id).to eq(comment.id)
      end
    end

    # this corresponds with the user clicking the upvote button twice, i.e. to remove
    # their vote.
    context "when a vote record exists for the user and comment and it's an upvote" do
      it "destroys it and returns a 200 status code" do
        login_as(user)
        create(:upvote, votable: comment, user: user)

        put "/api/v1/comments/#{comment.short_id}/upvotes"

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
      it "turns it into an upvote and returns a 200 status code" do
        login_as(user)
        create(:downvote, votable: comment, user: user)

        put "/api/v1/comments/#{comment.short_id}/upvotes"

        body = JSON.parse(response.body).symbolize_keys

        expect(response).to be_ok
        expect(body).to eq({
          short_id: comment.short_id,
          action: "upvoted"
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
