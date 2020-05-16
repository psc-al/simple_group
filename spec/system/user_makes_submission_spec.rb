RSpec.describe "user makes a submission" do
  include UrlHelpers

  let(:page) { CreateSubmissionPage.new }

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

    context "when the submission is for a URL" do
      it "creates the submission and redirects the user to the submission's view if successful" do
        url = "https://foo.com"
        stub_url_health_check(url)

        page.visit(as: user).
          fill_in_title("A Very Nice Title").
          fill_in_url(url).
          check_original_author.
          submit_form

        submission = Submission.first

        expect(Submission.count).to eq(1)
        expect(page).to have_current_path(submission_path(submission.short_id))
        expect(submission.title).to eq("A Very Nice Title")
        expect(submission.url).to eq(url)
        expect(submission.body).to be_nil
        expect(submission.original_author).to eq(true)
      end

      # i.e for redirects
      it "updates the URL to the final URL if it doesn't match the original" do
        url = "https://foo.com"
        stub_url_health_check(url, ending_url: "https://bar.foo.com")

        page.visit(as: user).
          fill_in_title("A Very Nice Title").
          fill_in_url(url).
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
        it "displays an error at the top of the page and doesn't save the submission" do
          create(:domain, :banned, name: "foo.com")
          url = "https:/foo.com/biz/baz"
          page.visit(as: user).
            fill_in_title("A Very Nice Title").
            fill_in_url(url).
            check_original_author.
            submit_form

          expect(Submission.count).to eq(0)
          expect(page).to have_invalid_url_error(url)
        end
      end

      context "when the URL scheme isn't HTTP or HTTPS" do
        it "displays an error at the top of the page and doesn't save the submission" do
          create(:domain, :banned, name: "foo.com")
          url = "ftp://foo@ftp.foo.com/biz/baz"
          page.visit(as: user).
            fill_in_title("A Very Nice Title").
            fill_in_url(url).
            check_original_author.
            submit_form

          expect(Submission.count).to eq(0)
          expect(page).to have_invalid_url_scheme_error("ftp")
        end
      end

      context "when the domain is banned" do
        it "displays an error at the top of the page and doesn't save the submission" do
          create(:domain, :banned, name: "foo.com")
          page.visit(as: user).
            fill_in_title("A Very Nice Title").
            fill_in_url("https://www.foo.com/biz/baz").
            check_original_author.
            submit_form

          expect(Submission.count).to eq(0)
          expect(page).to have_banned_domain_error("foo.com")
        end
      end

      context "when the URL healthcheck fails" do
        it "displays an error at the top of the page and doesn't save the submission" do
          url = "https://foo.com"
          stub_url_health_check(url, healthy: false)

          page.visit(as: user).
            fill_in_title("A Very Nice Title").
            fill_in_url(url).
            check_original_author.
            submit_form

          expect(Submission.count).to eq(0)
          expect(page).to have_url_health_error
        end
      end

      context "when as submission already exists for the URL" do
        it "displays an error at the top of the page and doesn't save the submission" do
          url = "https://foo.com"
          create(:submission, url: url)
          stub_url_health_check(url)

          page.visit(as: user).
            fill_in_title("A Very Nice Title").
            fill_in_url(url).
            check_original_author.
            submit_form

          expect(Submission.count).to eq(1)
          expect(page).to have_existing_submission_for_url_error
        end
      end
    end

    context "when the submission is a text submission" do
      it "creates the submission and redirects the user to the submission's view if successful" do
        page.visit(as: user).
          fill_in_title("A Very Nice Title").
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
      end
    end

    context "when the title is missing" do
      it "displays an error at the top of the page and doesn't save the submission" do
        page.visit(as: user).
          fill_in_body("This is a very nice submission body with some great info").
          check_original_author.
          submit_form

        expect(Submission.count).to eq(0)
        expect(page).to have_title_missing_error
      end
    end

    context "when the title is too short" do
      it "displays an error at the top of the page and doesn't save the submission" do
        page.visit(as: user).
          fill_in_title("tooshort").
          fill_in_body("This is a very nice submission body with some great info").
          check_original_author.
          submit_form

        expect(Submission.count).to eq(0)
        expect(page).to have_title_length_error
      end
    end

    context "when the title is too long" do
      it "displays an error at the top of the page and doesn't save the submission" do
        page.visit(as: user).
          fill_in_title("f" * 176).
          fill_in_body("This is a very nice submission body with some great info").
          check_original_author.
          submit_form

        expect(Submission.count).to eq(0)
        expect(page).to have_title_length_error
      end
    end

    context "when both the URL and body are missing" do
      it "displays an error at the top of the page and doesn't save the submission" do
        page.visit(as: user).
          check_original_author.
          submit_form

        expect(Submission.count).to eq(0)
        expect(page).to have_url_xor_body_error
      end
    end

    context "when both the URL and body are present" do
      it "displays an error at the top of the page and doesn't save the submission" do
        page.visit(as: user).
          fill_in_title("a very nice title").
          fill_in_body("lalalal la la laalla la").
          fill_in_url("https://www.url.com").
          check_original_author.
          submit_form

        expect(Submission.count).to eq(0)
        expect(page).to have_url_xor_body_error
      end
    end

    context "when the user tries to make a submission too soon after their last" do
      it "displays an error at the top of the page and doesn't save the submission" do
        now = Time.zone.now
        user = create(:user, last_submission_at: now)

        travel_to now + 5.minutes do
          page.visit(as: user).
            fill_in_title("a very nice title").
            fill_in_body("lalalal la la laalla la").
            check_original_author.
            submit_form

          expect(Submission.count).to eq(0)
          expect(page).to have_rate_limit_error(5)
        end
      end
    end
  end
end
