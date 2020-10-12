RSpec.describe "submission actions" do
  describe "PUT /users/submission_actions" do
    let(:user) { create(:user) }
    let(:submission) { create(:submission, :text) }

    context "when the user is logged in" do
      before { login_as(user) }

      context "when the action already exists" do
        # this is equivalent to clicking unsave / unhide
        it "destroys it" do
          create(:submission_action, :hidden, user: user, submission: submission)
          put "/users/submission_actions",
            params: {
              submission_action: {
                submission_short_id: submission.short_id, kind: :hidden
              }
            }

          expect(response).to be_ok
          expect(SubmissionAction.hidden.count).to eq(0)

          body = JSON.parse(response.body)

          expect(body).to eq({
            "status" => "unhidden",
            "text" => I18n.t("submissions.submission_list_item.actions.default.hidden")
          })
        end
      end

      context "when the underlying submission has been removed" do
        it "returns 404 not found" do
          submission = create(:submission_removal).submission

          put "/users/submission_actions",
            params: {
              submission_action: {
                submission_short_id: submission.short_id, kind: :hidden
              }
            }

          expect(response).to be_not_found
        end
      end

      context "when the action does not exist" do
        it "creates it" do
          put "/users/submission_actions",
            params: {
              submission_action: {
                submission_short_id: submission.short_id, kind: :hidden
              }
            }

          expect(response).to be_ok
          expect(SubmissionAction.hidden.count).to eq(1)
          expect(SubmissionAction.where(user: user, submission: submission)).to exist

          body = JSON.parse(response.body)

          expect(body).to eq({
            "status" => "hidden",
            "text" => I18n.t("submissions.submission_list_item.actions.created.hidden")
          })
        end
      end
    end

    context "when the user is not logged in" do
      it "returns a 403 status code" do
        put "/users/submission_actions",
          params: {
            submission_action: {
              submission_short_id: submission.short_id, kind: :hidden
            }
          }

        expect(response).to be_forbidden
        expect(SubmissionAction.hidden.count).to eq(0)
      end
    end
  end
end
