RSpec.describe "user makes a submission" do
  include UrlHelpers

  let(:page) { CreateSubmissionPage.new }
  let!(:tag) { create(:topic_tag) }

  context "when the user is not signed in" do
    it "redirects the user to the login page" do
      # no user context
      page.visit(as: nil)

      # kind of a weird way to test this but there isn't a good
      # way to do it otherwise in a system spec.
      expect(page).to have_current_path(new_user_session_path)
    end
  end

  context "when the user is signed in" do
    let(:user) { create(:user) }

    context "when the user switches between URL and text tabs", js: true do
      it "displays the correct form elements" do
        page.visit(as: user).
          click_text_tab

        expect(page).to have_submission_body_text_box
        expect(page).not_to have_submission_url_text_box

        page.visit(as: user).
          click_link_tab

        expect(page).to have_submission_url_text_box
        expect(page).not_to have_submission_body_text_box
      end
    end

    context "when the submission is for a URL" do
      it "creates the submission, automagically upvotes it, and redirects the user to it if successful" do
        url = "https://foo.com"
        stub_url_health_check(url)

        page.visit(as: user).
          fill_in_title("A Very Nice Title").
          fill_in_url(url).
          select_tag(tag.id).
          check_original_author.
          submit_form

        submission = Submission.first

        expect(Submission.count).to eq(1)
        expect(page).to have_current_path(submission_path(submission.short_id))
        expect(submission.title).to eq("A Very Nice Title")
        expect(submission.url).to eq(url)
        expect(submission.body).to be_nil
        expect(submission.original_author).to eq(true)
        expect(submission.votes.upvote.count).to eq(1)
        expect(submission.votes.upvote.first.user_id).to eq(user.id)
      end

      # i.e for redirects
      it "updates the URL to the final URL if it doesn't match the original" do
        url = "https://foo.com"
        stub_url_health_check(url, ending_url: "https://bar.foo.com")

        page.visit(as: user).
          fill_in_title("A Very Nice Title").
          fill_in_url(url).
          select_tag(tag.id).
          check_original_author.
          submit_form

        submission = Submission.first

        expect(Submission.count).to eq(1)
        expect(page).to have_current_path(submission_path(submission.short_id))
        expect(submission.title).to eq("A Very Nice Title")
        expect(submission.url).to eq("https://bar.foo.com")
        expect(submission.body).to be_nil
        expect(submission.original_author).to eq(true)
      end

      context "when the URL is malformed" do
        it "displays an error and doesn't save the submission" do
          create(:domain, :banned, name: "foo.com")
          url = "https:/foo.com/biz/baz"
          page.visit(as: user).
            fill_in_title("A Very Nice Title").
            fill_in_url(url).
            select_tag(tag.id).
            check_original_author.
            submit_form

          expect(Submission.count).to eq(0)
          expect(page).to have_invalid_url_error(url)
        end
      end

      context "when the URL scheme isn't HTTP or HTTPS" do
        it "displays an error and doesn't save the submission" do
          create(:domain, :banned, name: "foo.com")
          url = "ftp://foo@ftp.foo.com/biz/baz"
          page.visit(as: user).
            fill_in_title("A Very Nice Title").
            fill_in_url(url).
            select_tag(tag.id).
            check_original_author.
            submit_form

          expect(Submission.count).to eq(0)
          expect(page).to have_invalid_url_scheme_error("ftp")
        end
      end

      context "when the domain is banned" do
        it "displays an error and doesn't save the submission" do
          create(:domain, :banned, name: "foo.com")
          page.visit(as: user).
            fill_in_title("A Very Nice Title").
            fill_in_url("https://www.foo.com/biz/baz").
            select_tag(tag.id).
            check_original_author.
            submit_form

          expect(Submission.count).to eq(0)
          expect(page).to have_banned_domain_error("foo.com")
        end
      end

      context "when the URL healthcheck fails" do
        it "displays an error and doesn't save the submission" do
          url = "https://foo.com"
          stub_url_health_check(url, healthy: false)

          page.visit(as: user).
            fill_in_title("A Very Nice Title").
            fill_in_url(url).
            select_tag(tag.id).
            check_original_author.
            submit_form

          expect(Submission.count).to eq(0)
          expect(page).to have_url_health_error
        end
      end

      context "when as submission already exists for the URL" do
        it "displays an error and doesn't save the submission" do
          url = "https://foo.com"
          create(:submission, url: url)
          stub_url_health_check(url)

          page.visit(as: user).
            fill_in_title("A Very Nice Title").
            fill_in_url(url).
            select_tag(tag.id).
            check_original_author.
            submit_form

          expect(Submission.count).to eq(1)
          expect(page).to have_existing_submission_for_url_error
        end
      end
    end

    context "when the submission is a text submission", js: true do
      it "creates the submission, automagically upvotes it, and redirects the user to it if successful" do
        page.visit(as: user).
          fill_in_title("A Very Nice Title").
          select_tag(tag.id).
          click_text_tab.
          fill_in_body("This is a very nice submission body").
          check_original_author.
          submit_form

        submission = Submission.first

        expect(Submission.count).to eq(1)
        expect(page).to have_current_path(submission_path(submission.short_id))
        expect(submission.title).to eq("A Very Nice Title")
        expect(submission.url).to be_nil
        expect(submission.body).to eq("This is a very nice submission body")
        expect(submission.original_author).to eq(true)
        expect(submission.votes.upvote.count).to eq(1)
        expect(submission.votes.upvote.first.user_id).to eq(user.id)
      end
    end

    context "when the title is missing", js: true do
      it "displays an error and doesn't save the submission" do
        page.visit(as: user).
          click_text_tab.
          fill_in_body("This is a very nice submission body with some great info").
          select_tag(tag.id).
          check_original_author.
          submit_form

        expect(Submission.count).to eq(0)
        expect(page).to have_title_missing_error
      end
    end

    context "when the title is too short", js: true do
      it "displays an error and doesn't save the submission" do
        page.visit(as: user).
          fill_in_title("tooshort").
          click_text_tab.
          fill_in_body("This is a very nice submission body with some great info").
          check_original_author.
          submit_form

        expect(Submission.count).to eq(0)
        expect(page).to have_title_too_short_error("8")
      end
    end

    context "when the more than 175 chars are entered for the title", js: true do
      it "only has 175 chars" do
        page.visit(as: user).
          fill_in_title("f" * 176)

        expect(page).to have_title_with_x_chars(175)
      end
    end

    context "when both the URL and body are missing" do
      it "displays an error and doesn't save the submission" do
        page.visit(as: user).
          select_tag(tag.id).
          check_original_author.
          submit_form

        expect(Submission.count).to eq(0)
        expect(page).to have_url_xor_body_error
      end
    end

    context "when the user tries to make a submission too soon after their last", js: true do
      it "displays an error and doesn't save the submission" do
        now = Time.zone.now
        user = create(:user, last_submission_at: now)

        travel_to now + 5.minutes do
          page.visit(as: user).
            fill_in_title("a very nice title").
            select_tag(tag.id).
            click_text_tab.
            fill_in_body("lalalal la la laalla la").
            check_original_author.
            submit_form

          expect(Submission.count).to eq(0)
          expect(page).to have_rate_limit_error(5)
        end
      end
    end

    context "when no tag is selected", js: true do
      it "displays an error and doesn't save the submission" do
        page.visit(as: user).
          fill_in_title("A Very Nice Title").
          click_text_tab.
          fill_in_body("This is a very nice submission body").
          check_original_author.
          submit_form

        expect(Submission.count).to eq(0)
        expect(page).to have_missing_tags_error
      end
    end

    context "when too many tags are selected", js: true do
      it "displays an error and doesn't save the submission" do
        tags = create_list(:topic_tag, 6)
        page.visit(as: user).
          fill_in_title("A Very Nice Title").
          click_text_tab.
          fill_in_body("This is a very nice submission body").
          check_original_author

        tags.each { |t| page.select_tag(t.id) }

        page.submit_form

        expect(Submission.count).to eq(0)
        expect(page).to have_tags_max_error
      end
    end

    context "when there are no non-media tags selected", js: true do
      it "displays an error and doesn't save the submission" do
        media_tag = create(:media_tag)
        page.visit(as: user).
          fill_in_title("A Very Nice Title").
          click_text_tab.
          fill_in_body("This is a very nice submission body").
          select_tag(media_tag.id).
          check_original_author

        page.submit_form

        expect(Submission.count).to eq(0)
        expect(page).to have_tag_media_error
      end
    end
  end
end
