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
end
