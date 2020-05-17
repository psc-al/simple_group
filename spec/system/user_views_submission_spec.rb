RSpec.describe "user views submission" do
  let(:user) { create(:user) }

  context "when the submitter is the original author" do
    it "shows that the submitter is the author" do
      submission = create(:submission, :url, original_author: true)

      page = ViewSubmissionPage.new

      page.visit(submission, as: user)

      expect(page).to have_authored_by(submission.user)
    end
  end

  context "when the submitter is not the original author" do
    it "does not state that the submitter is the original author" do
      submission = create(:submission, :url, original_author: false)

      page = ViewSubmissionPage.new

      page.visit(submission, as: user)

      expect(page).to have_submitted_by(submission.user)
    end
  end

  context "when the submission is for a URL" do
    it "displays the submission information and links to the external URL" do
      submission = create(:submission, :url)

      page = ViewSubmissionPage.new

      page.visit(submission, as: user)

      expect(page).to have_correct_submission_link(submission)
    end
  end

  context "when the submission is a text submission" do
    it "displays the submission information and body, and links to itself" do
      submission = create(:submission, :text)

      page = ViewSubmissionPage.new

      page.visit(submission, as: user)

      expect(page).to have_correct_submission_link(submission)
      expect(page).to have_plain_text_submission_body(submission.body)
    end

    context "when there is markdown in the submission body" do
      it "displays the markdown formatted submission body" do
        body = "# A markdown header\n- items\n- in\n-a\n- list\n```\ncode block\n```"
        submission = create(:submission, :text, body: body)

        page = ViewSubmissionPage.new

        page.visit(submission, as: user)

        within find(".submission-body") do
          expect(page).to have_css("h1", text: "A markdown header")
          within find("ul") do
            expect(page).to have_css("li", text: "items")
            expect(page).to have_css("li", text: "in")
            expect(page).to have_css("li", text: "a")
            expect(page).to have_css("li", text: "list")
          end
          expect(page).to have_css("pre code", text: "code block")
        end
      end
    end

    context "when there is LaTeX in the submission body (oh boy)", js: true do
      # I'm not going to test every little thing here given that the
      # katex library itself should take care of making sure that it
      # works as advertised.
      it "displays the LaTeX in katex nodes within the body" do
        body = "\\(f(x)=x^2\\)\n$$g(x)=x^3$$\n\\[h(x)=x^4\\]"
        submission = create(:submission, :text, body: body)

        page = ViewSubmissionPage.new

        page.visit(submission, as: user)

        within find(".submission-body") do
          expect(page).to have_css(".katex .katex-mathml") # inline display
          expect(page.all(:css, ".katex-display").length).to eq(2) # should be two display mode renderings
        end
      end
    end

    it "can see the submission's tags" do
      body = "\\(f(x)=x^2\\)\n$$g(x)=x^3$$\n\\[h(x)=x^4\\]"
      submission = create(:submission, :text, :with_all_tags, body: body)

      page = ViewSubmissionPage.new

      page.visit(submission, as: user)

      submission.tags.each do |tag|
        expect(page).to have_tag(tag)
      end
    end
  end

  # if for whatever reason a user decides to view a submission that
  # they have hidden, we should display the proper action link
  context "when a submission was hidden by a user" do
    context "when that user is on the submission page" do
      it "indicates that the submission is hidden" do
        page = ViewSubmissionPage.new
        user = create(:user)
        hidden_submission = create(:submission, :text)
        create(:submission_action, :hidden, user: user, submission: hidden_submission)

        page.visit(hidden_submission, as: user)

        expect(page).to have_hidden_submission_link(hidden_submission)
      end
    end

    context "when another user is on the submission page" do
      it "does not indicate that the submission is hidden" do
        page = ViewSubmissionPage.new
        user = create(:user)
        user2 = create(:user)
        hidden_submission = create(:submission, :text)
        create(:submission_action, :hidden, user: user, submission: hidden_submission)

        page.visit(hidden_submission, as: user2)

        expect(page).not_to have_hidden_submission_link(hidden_submission)
      end
    end

    context "when a signed out user is on the submission page" do
      it "does not indicate that the submission is hidden" do
        page = ViewSubmissionPage.new
        user = create(:user)
        hidden_submission = create(:submission, :text)
        create(:submission_action, :hidden, user: user, submission: hidden_submission)

        page.visit(hidden_submission, as: nil)

        expect(page).not_to have_hidden_submission_link(hidden_submission)
      end
    end
  end

  context "when a submission was saved by a user" do
    context "when that user is on the submission page" do
      it "indicates that the submission is saved" do
        page = ViewSubmissionPage.new
        user = create(:user)
        saved_submission = create(:submission, :text)
        create(:submission_action, :saved, user: user, submission: saved_submission)

        page.visit(saved_submission, as: user)

        expect(page).to have_saved_submission(saved_submission)
      end
    end

    context "when another user is on the submission page" do
      it "does not indicate that the submission is saved" do
        page = ViewSubmissionPage.new
        user = create(:user)
        user2 = create(:user)
        saved_submission = create(:submission, :text)
        create(:submission_action, :saved, user: user, submission: saved_submission)

        page.visit(saved_submission, as: user2)

        expect(page).not_to have_saved_submission(saved_submission)
      end
    end

    context "when a signed out user is on the submission page" do
      it "does not indicate that the submission is saved" do
        page = ViewSubmissionPage.new
        user = create(:user)
        saved_submission = create(:submission, :text)
        create(:submission_action, :saved, user: user, submission: saved_submission)

        page.visit(saved_submission, as: nil)

        expect(page).not_to have_saved_submission(saved_submission)
      end
    end
  end

  context "when a user clicks the submission action links", js: true do
    context "when the user is logged in" do
      let(:user) { create(:user) }

      it "can add a submission to the user's saved submissions" do
        submission = create(:submission, :with_all_tags)
        page = ViewSubmissionPage.new

        page.visit(submission, as: user)

        page.hide_submission(submission)

        expect(page).to have_hidden_submission(submission)
        expect(SubmissionAction.hidden.where(user: user, submission: submission)).to exist
      end

      it "can add a submission to the user's hidden submissions" do
        submission = create(:submission, :with_all_tags)
        page = ViewSubmissionPage.new

        page.visit(submission, as: user)

        page.save_submission(submission)

        expect(page).to have_saved_submission(submission)
        expect(SubmissionAction.saved.where(user: user, submission: submission)).to exist
      end
    end

    context "when the user is not logged in" do
      it "does not do anything" do
        submission = create(:submission, :with_all_tags)
        page = ViewSubmissionPage.new

        page.visit(submission, as: nil)

        page.save_submission(submission)
        page.hide_submission(submission)

        expect(page).to have_save_submission_link(submission)
        expect(page).to have_hide_submission_link(submission)
        expect(SubmissionAction.count).to eq(0)
      end
    end
  end
end
