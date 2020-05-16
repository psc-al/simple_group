RSpec.describe CreateSubmissionForm do
  include UrlHelpers

  let(:user) { create(:user) }
  let(:i18n_error_prefix) { CreateSubmissionForm::I18N_PREFIX }

  describe "#save" do
    it "updates the user's `last_submission_time` when successful" do
      now = Time.zone.now.change(usec: 0)
      travel_to now do
        params = { title: "Foo bar biz", body: "abcd1234", original_author: "1" }

        expect(user.last_submission_at).to be_nil

        form = CreateSubmissionForm.new(params, user)

        form.save

        expect(user.last_submission_at).to eq(now)
      end
    end

    it "does not update the user's `last_submission_time` when unsuccessful" do
      params = { body: "abcd1234", original_author: "1" }

      form = CreateSubmissionForm.new(params, user)

      expect(user.last_submission_at).to be_nil

      form.save

      expect(user.last_submission_at).to be_nil
    end

    # we can probably do some more validations on this but
    # for now making a text submission is pretty easy.
    context "when the submission is a text submission" do
      context "when the submission is valid" do
        it "persists the submission" do
          params = { title: "Foo bar biz", body: "abcd1234", original_author: "1" }

          form = CreateSubmissionForm.new(params, user)

          form.save

          submission = form.submission

          expect(submission).to be_persisted

          expect(submission.title).to eq("Foo bar biz")
          expect(submission.body).to eq("abcd1234")
          expect(submission).to be_original_author
        end
      end
    end

    context "when the submission involves a URL and is valid" do
      context "when the domain has not been seen before" do
        it "creates a new submission record and domain record" do
          url = "http://foobar.com"
          params = { title: "Foo to the bar, biz, and baz", url: url }
          stub_url_health_check(url)

          form = CreateSubmissionForm.new(params, user)

          form.save

          submission = form.submission
          domain = Domain.find_by(name: "foobar.com")

          # make sure domain got created
          expect(Domain.count).to eq(1)
          expect(domain).to be_a(Domain)
          expect(submission).to be_persisted
          expect(submission.title).to eq("Foo to the bar, biz, and baz")
          expect(submission.url).to eq("http://foobar.com")
          expect(submission.domain).to eq(domain)
          expect(submission.body).to be_nil
          expect(submission).not_to be_original_author
          expect(submission.user).to eq(user)
        end
      end

      context "when there is an existing record for the domain" do
        it "assigns the submission the existing domain record and saves the submission" do
          url = "http://foobar.com"
          params = { title: "Foo to the bar, biz, and baz", url: url }
          stub_url_health_check(url)
          domain = create(:domain, name: "foobar.com")

          form = CreateSubmissionForm.new(params, user)

          form.save

          submission = form.submission

          expect(Domain.count).to eq(1)
          expect(submission).to be_persisted
          expect(submission.title).to eq("Foo to the bar, biz, and baz")
          expect(submission.url).to eq("http://foobar.com")
          expect(submission.domain).to eq(domain)
          expect(submission.body).to be_nil
          expect(submission.original_author).to eq(false)
          expect(submission.user).to eq(user)
        end
      end
    end

    context "when the submission involves a URL and is not valid" do
      context "when the domain is banned" do
        it "adds a domain error and does not persist the submission" do
          url = "http://foobar.com"
          params = { title: "Foo to the bar, biz, and baz", url: url }
          stub_url_health_check(url)
          domain = create(:domain, :banned, name: "foobar.com")

          form = CreateSubmissionForm.new(params, user)

          form.save

          submission = form.submission

          expect(submission).not_to be_persisted
          expect(form.errors[:domain]).
            to include(I18n.t("#{i18n_error_prefix}.banned_domain", domain: domain.name))
        end
      end

      # i.e. URL A gets redirected to URL B, which is banned
      # maybe someone tried to pull a fast one, or didn't know.
      context "when the redirected domain is banned" do
        it "adds a domain error and does not persist the submission" do
          url = "http://foobar.com"
          params = { title: "Foo to the bar, biz, and baz", url: url }
          stub_url_health_check(url, ending_url: "http://barfoo.com")
          domain = create(:domain, :banned, name: "barfoo.com")

          form = CreateSubmissionForm.new(params, user)

          form.save

          submission = form.submission

          expect(submission).not_to be_persisted
          expect(form.errors[:domain]).
            to include(I18n.t("#{i18n_error_prefix}.banned_domain", domain: domain.name))
        end
      end

      context "when the URL fails health checks" do
        it "adds a url health error and does not persist the submission" do
          url = "http://foobar.com"
          params = { title: "Foo to the bar, biz, and baz", url: url }
          stub_url_health_check(url, healthy: false)

          form = CreateSubmissionForm.new(params, user)

          form.save

          submission = form.submission

          expect(submission).not_to be_persisted
          expect(form.errors[:url]).to include(I18n.t("#{i18n_error_prefix}.url_health"))
        end
      end

      context "when there is an issue with the URL itself" do
        it "adds a url error when the URL scheme is not http or https and does not persist submission" do
          url = "htt://foobar.com"
          params = { title: "Foo to the bar, biz, and baz", url: url }

          form = CreateSubmissionForm.new(params, user)

          form.save

          submission = form.submission

          expect(submission).not_to be_persisted
          expect(form.errors[:url]).to include(I18n.t("url.error.scheme", scheme: "htt"))
        end

        # I would ask when this would ever happen but users never surprise me
        it "adds a url error when the URL doesn't have a host and does not persist the submission" do
          url = "http://"
          params = { title: "Foo to the bar, biz, and baz", url: url }

          form = CreateSubmissionForm.new(params, user)

          form.save

          submission = form.submission

          expect(submission).not_to be_persisted
          expect(form.errors[:url]).to include(I18n.t("url.error.invalid", url: url))
        end
      end

      context "when the URL has already been submitted" do
        it "does not persist the submission and adds an error to the error list" do
          url = "http://foobar.com"
          create(:submission, :url, url: url)
          params = { title: "Foo to the bar, biz, and baz", url: url }
          stub_url_health_check(url)

          form = CreateSubmissionForm.new(params, user)

          form.save

          submission = form.submission

          expect(submission).not_to be_persisted
          expect(form.errors[:url]).to include(I18n.t("#{i18n_error_prefix}.url_exists"))
        end
      end
    end

    context "when there is both a URL and a submission body" do
      it "adds a base error and does not persist the submission" do
        url = "http://foobar.com"
        params = { title: "Foo to the bar, biz, and baz", url: url, body: "abcd12323423234" }
        stub_url_health_check(url)

        form = CreateSubmissionForm.new(params, user)

        form.save

        submission = form.submission

        expect(submission).not_to be_persisted
        expect(form.errors[:base]).to include(I18n.t("#{i18n_error_prefix}.url_or_body"))
      end
    end

    context "when the title is missing" do
      it "adds an error and doesn't persist the submission" do
        url = "http://foobar.com"
        params = { body: "abcd12323423234" }
        stub_url_health_check(url)

        form = CreateSubmissionForm.new(params, user)

        form.save

        submission = form.submission

        expect(submission).not_to be_persisted
        expect(form.errors[:title]).to include(
          I18n.t("#{i18n_error_prefix}.title_missing")
        )
      end
    end

    context "when the title is too short" do
      it "adds an error and doesn't persist the submission" do
        url = "http://foobar.com"
        params = { title: "abc", body: "abcd12323423234" }
        stub_url_health_check(url)

        form = CreateSubmissionForm.new(params, user)

        form.save

        submission = form.submission

        expect(submission).not_to be_persisted
        expect(form.errors[:title]).to include(
          I18n.t("#{i18n_error_prefix}.title_length")
        )
      end
    end

    context "when the title is too long" do
      it "adds an error and doesn't persist the submission" do
        url = "http://foobar.com"
        params = { title: ("abc" * 100), body: "abcd12323423234" }
        stub_url_health_check(url)

        form = CreateSubmissionForm.new(params, user)

        form.save

        submission = form.submission

        expect(submission).not_to be_persisted
        expect(form.errors[:title]).to include(
          I18n.t("#{i18n_error_prefix}.title_length")
        )
      end
    end

    context "when the user has tries to make a submission too soon after their last" do
      it "adds an error and doesn't persist the submission" do
        now = Time.zone.now

        travel_to now + 5.minutes do
          params = { title: "a very wonderfully great title", body: "abcd12323423234" }
          form = CreateSubmissionForm.new(params, build(:user, last_submission_at: now))

          form.save

          submission = form.submission

          expect(submission).not_to be_persisted
          expect(form.errors[:user]).to include(
            I18n.t("#{i18n_error_prefix}.rate_limit", try_again_min: 5)
          )
        end
      end
    end
  end
end
