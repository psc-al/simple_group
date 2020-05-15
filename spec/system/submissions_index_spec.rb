RSpec.describe "submissions index" do
  context "when a user visits the submission index" do
    it "can view a list of submissions in descending order by default" do
      submissions = create_pair(:submission, :with_all_tags)
      page = SubmissionsIndexPage.new

      page.visit

      submissions.each do |s|
        expect(page).to have_submission_row_for(s)
      end

      submission = submissions.last

      expect(find(".submissions-list ol li", match: :first)).
        to have_css(".submission-line1", text: submission.title)
    end
  end

  context "when paginating results" do
    context "when there are multiple pages" do
      it "can page through them" do
        # this is hacky as hell I know, but I don't want to
        # create a ton of submissions as part of this setup
        # to get it to page, so we'll do this for now.
        # Open to better ways to do it.
        stub_const("SubmissionSearch::DEFAULT_PER_PAGE", 2)
        s1, s2, s3, s4, s5 = create_list(:submission, 5, :with_all_tags)
        page = SubmissionsIndexPage.new

        page.visit

        expect(page).to have_next_page
        expect(page).not_to have_previous_page

        [s5, s4].each { |s| expect(page).to have_submission_row_for(s) }
        [s1, s2, s3].each { |s| expect(page).not_to have_submission_row_for(s) }

        # forward
        page.next_page

        expect(page).to have_next_page
        expect(page).to have_previous_page

        [s3, s2].each { |s| expect(page).to have_submission_row_for(s) }
        [s1, s4, s5].each { |s| expect(page).not_to have_submission_row_for(s) }

        page.next_page

        expect(page).not_to have_next_page
        expect(page).to have_previous_page

        expect(page).to have_submission_row_for(s1)
        [s2, s3, s4, s5].each { |s| expect(page).not_to have_submission_row_for(s) }

        # and back
        page.previous_page

        expect(page).to have_next_page
        expect(page).to have_previous_page

        [s3, s2].each { |s| expect(page).to have_submission_row_for(s) }
        [s1, s4, s5].each { |s| expect(page).not_to have_submission_row_for(s) }
      end
    end

    context "when there is only one page" do
      it "there are no paging controls" do
        submission = create(:submission, :with_all_tags)
        page = SubmissionsIndexPage.new

        page.visit

        expect(page).to have_submission_row_for(submission)
        expect(page).not_to have_next_page
        expect(page).not_to have_previous_page
      end
    end
  end
end
