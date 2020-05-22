RSpec.describe "user views a user's submissions" do
  let(:page) { UserSubmissionsIndexPage.new }
  let(:user) { create(:user) }

  context "when a user is logged in" do
    it "can view their own submissions" do
      user_submission = create(:submission, :text, user: user)
      other_submission = create(:submission, :text)

      page.visit(user, as: user)

      expect(page).to have_submission_row_for(user_submission)
      expect(page).not_to have_submission_row_for(other_submission)
    end

    it "can view another user's submissions" do
      user_submission = create(:submission, :text, user: user)
      other_submission = create(:submission, :text)

      page.visit(other_submission.user, as: user)

      expect(page).not_to have_submission_row_for(user_submission)
      expect(page).to have_submission_row_for(other_submission)
    end
  end

  context "when a user is not logged in" do
    it "can view another user's submissions" do
      user_submission = create(:submission, :text, user: user)
      other_submission = create(:submission, :text)

      page.visit(user, as: nil)

      expect(page).to have_submission_row_for(user_submission)
      expect(page).not_to have_submission_row_for(other_submission)
    end
  end
end
