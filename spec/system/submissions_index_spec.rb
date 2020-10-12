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

    it "does not show removed submissions" do
      submission = create(:submission_removal).submission

      page = SubmissionsIndexPage.new

      page.visit

      expect(page).not_to have_submission_row_for(submission)
    end
  end

  context "when paginating results" do
    context "when there are multiple pages" do
      it "can page through them" do
        # this is hacky as hell I know, but I don't want to
        # create a ton of submissions as part of this setup
        # to get it to page, so we'll do this for now.
        # Open to better ways to do it.
        stub_const("FlattenedSubmissionSearch::DEFAULT_PER_PAGE", 2)
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

  context "when a submission was hidden by a user" do
    context "when that user is on the index page" do
      it "does not display that submission" do
        page = SubmissionsIndexPage.new
        user = create(:user)
        visible_submission = create(:submission, :text)
        hidden_submission = create(:submission, :text)
        create(:submission_action, :hidden, user: user, submission: hidden_submission)

        page.visit(as: user)

        expect(page).to have_submission_row_for(visible_submission)
        expect(page).not_to have_submission_row_for(hidden_submission)
      end
    end

    # i.e. we only hide submissions for the user that has
    # hidden it. This should be obvious but it's worth
    # having a test for.
    context "when another user is on the index page" do
      it "displays the submission" do
        page = SubmissionsIndexPage.new
        user = create(:user)
        user2 = create(:user)
        visible_submission = create(:submission, :text)
        hidden_submission = create(:submission, :text)
        create(:submission_action, :hidden, user: user, submission: hidden_submission)

        page.visit(as: user2)

        expect(page).to have_submission_row_for(visible_submission)
        expect(page).to have_submission_row_for(hidden_submission)
      end
    end

    context "when a signed out user is on the index page" do
      it "displays the submission" do
        page = SubmissionsIndexPage.new
        user = create(:user)
        visible_submission = create(:submission, :text)
        hidden_submission = create(:submission, :text)
        create(:submission_action, :hidden, user: user, submission: hidden_submission)

        page.visit

        expect(page).to have_submission_row_for(visible_submission)
        expect(page).to have_submission_row_for(hidden_submission)
      end
    end
  end

  context "when a submission was saved by a user" do
    context "when that user is on the index page" do
      it "indicates that the submission is saved" do
        page = SubmissionsIndexPage.new
        user = create(:user)
        saved_submission = create(:submission, :text)
        create(:submission_action, :saved, user: user, submission: saved_submission)

        page.visit(as: user)

        expect(page).to have_submission_row_for(saved_submission)
        expect(page).to have_saved_submission(saved_submission)
      end
    end

    # similar to above, the submission should only show as "saved"
    # to the user that saved it.
    context "when another user is on the index page" do
      it "does not indicate that the submission is saved" do
        page = SubmissionsIndexPage.new
        user = create(:user)
        user2 = create(:user)
        saved_submission = create(:submission, :text)
        create(:submission_action, :saved, user: user, submission: saved_submission)

        page.visit(as: user2)

        expect(page).to have_submission_row_for(saved_submission)
        expect(page).not_to have_saved_submission(saved_submission)
      end
    end

    context "when a signed out user is on the index page" do
      it "does not indicate that the submission is saved" do
        page = SubmissionsIndexPage.new
        user = create(:user)
        saved_submission = create(:submission, :text)
        create(:submission_action, :saved, user: user, submission: saved_submission)

        page.visit

        expect(page).to have_submission_row_for(saved_submission)
        expect(page).not_to have_saved_submission(saved_submission)
      end
    end
  end

  context "when a user clicks the submission action links", js: true do
    context "when the user is logged in" do
      let(:user) { create(:user) }

      it "can add a submission to the user's saved submissions" do
        submission = create(:submission, :with_all_tags)
        page = SubmissionsIndexPage.new

        page.visit(as: user)

        page.hide_submission(submission)

        expect(page).to have_hidden_submission(submission)
        expect(SubmissionAction.hidden.where(user: user, submission: submission)).to exist
      end

      it "can add a submission to the user's hidden submissions" do
        submission = create(:submission, :with_all_tags)
        page = SubmissionsIndexPage.new

        page.visit(as: user)

        page.save_submission(submission)

        expect(page).to have_saved_submission(submission)
        expect(SubmissionAction.saved.where(user: user, submission: submission)).to exist
      end
    end

    context "when the user is not logged in" do
      it "does not do anything" do
        submission = create(:submission, :with_all_tags)
        page = SubmissionsIndexPage.new

        page.visit(as: nil)

        page.save_submission(submission)
        page.hide_submission(submission)

        expect(page).to have_save_submission_link(submission)
        expect(page).to have_hide_submission_link(submission)
        expect(SubmissionAction.count).to eq(0)
      end
    end
  end

  context "when a user clicks on the submission's tag" do
    it "sees all submissions that have the same tag, excluding others" do
      tag = create(:topic_tag)
      s1 = create(:submission, :text, tags: [tag])
      s2 = create(:submission, :text)

      page = SubmissionsIndexPage.new

      page.visit(as: nil)

      page.click_tag_link_on(s1, tag)

      expect(page).to have_submission_row_for(s1)
      expect(page).not_to have_submission_row_for(s2)
    end
  end
end
