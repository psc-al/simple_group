RSpec.describe "Admin removes submission" do
  let(:admin) { create(:user, :admin) }
  let!(:submission) { create(:submission, :url) }

  context "when an admin clicks remove on a submission" do
    let(:page) { SubmissionsIndexPage.new }

    it "gets sent to the submission removal form page" do
      page.visit(as: admin)

      page.click_remove_submission(submission)

      expect(page).to have_current_path(
        new_admin_submission_removal_path(submission_removal: {
          submission_short_id: submission.short_id
        })
      )
    end
  end

  context "when an admin submits the submission removal form" do
    let(:page) { Admin::RemoveSubmissionPage.new(submission) }

    it "creates a submission removal record" do
      page.visit(as: admin).select_reason("spam").fill_in_details("spammy mc spam stix").submit_form

      expect(submission.reload).to be_removed
      expect(submission.submission_removal.removed_by).to eq(admin)
      expect(submission.submission_removal.details).to eq("spammy mc spam stix")
      expect(submission.submission_removal).to be_spam
    end
  end

  context "when an admin wants to reverse the removal", js: true do
    let(:page) { Admin::SubmissionRemovalsIndexPage.new }

    it "clicks the undo link on the submission index and confirms and undos the removal" do
      removal = create(:submission_removal)
      submission = removal.submission

      expect(submission).to be_removed

      page.visit(as: admin)

      expect(page).to have_removal_row(removal)

      page.undo_removal(removal)

      expect(page).not_to have_removal_row(removal)

      submission.reload

      expect(SubmissionRemoval.where(id: removal.id)).not_to exist
      expect(submission).not_to be_removed
    end
  end
end
