RSpec.describe SubmissionsHelper do
  describe "#submission_href_for" do
    context "when the submission has a URL" do
      it "is the URL" do
        submission = build(:submission, url: "https://www.foo.com")

        expect(helper.submission_href_for(submission)).to eq("https://www.foo.com")
      end
    end

    context "when the submission does not have a URL" do
      it "is the link to the submission" do
        submission = create(:submission, url: nil)

        expect(helper.submission_href_for(submission)).to eq(submission_path(submission.short_id))
      end
    end
  end

  describe "#submitted_by_text" do
    context "when the user who made the submission is the original author" do
      it "is the relevant `authored_by` translation" do
        submission = build(:submission, original_author: true)

        expect(helper.submitted_by_text(submission)).
          to eq(t("submissions.submission_list_item.authored_by"))
      end
    end

    context "when the user who made the submission is not the original author" do
      it "is the relevant `submitted_by` translation" do
        submission = build(:submission, original_author: false)

        expect(helper.submitted_by_text(submission)).
          to eq(t("submissions.submission_list_item.submitted_by"))
      end
    end
  end

  describe "#submitted_time_text" do
    it "says how long ago the submission was submitted" do
      travel_to Time.zone.local(2020) do
        created = 1.hour.ago

        submission = build(:submission, created_at: created)

        expect(helper.submitted_time_text(submission)).to eq(
          "#{t('datetime.distance_in_words.about_x_hours.one')} "\
          "#{t('submissions.submission_list_item.ago')}"
        )
      end
    end
  end

  describe "#saved_class_for" do
    context "when `saved_action_id` is defined on the submission" do
      it "returns `submission-saved` when the id is present" do
        create(:submission, :text)
        submission = Submission.select("*, 666 AS saved_action_id").first

        expect(helper.saved_class_for(submission)).to eq("submission-saved")
      end

      it "returns the empty string when the id is nil" do
        create(:submission, :text)
        submission = Submission.select("*, NULL AS saved_action_id").first

        expect(helper.saved_class_for(submission)).to eq("")
      end
    end

    context "when `saved_action_id` is not defined on the submission" do
      it "raises an error" do
        submission = build(:submission, :text)

        expect { helper.saved_class_for(submission) }.to raise_error(NoMethodError)
      end
    end
  end

  describe "#save_link_text_for" do
    context "when `saved_action_id` is defined on the submission" do
      it "returns `submission-saved` when the id is present" do
        create(:submission, :text)
        submission = Submission.select("*, 666 AS saved_action_id").first

        expect(helper.save_link_text_for(submission)).
          to eq(t("submissions.submission_list_item.actions.created.saved"))
      end

      it "returns the empty string when the id is nil" do
        create(:submission, :text)
        submission = Submission.select("*, NULL AS saved_action_id").first

        expect(helper.save_link_text_for(submission)).
          to eq(t("submissions.submission_list_item.actions.default.saved"))
      end
    end

    context "when `saved_action_id` is not defined on the submission" do
      it "raises an error" do
        submission = build(:submission, :text)

        expect { helper.saved_link_text_for(submission) }.to raise_error(NoMethodError)
      end
    end
  end

  describe "#hide_link_text_for" do
    context "when `saved_action_id` is defined on the submission" do
      it "returns `submission-saved` when the id is present" do
        create(:submission, :text)
        submission = Submission.select("*, 666 AS hidden_action_id").first

        expect(helper.hide_link_text_for(submission)).
          to eq(t("submissions.submission_list_item.actions.created.hidden"))
      end

      it "returns the empty string when the id is nil" do
        create(:submission, :text)
        submission = Submission.select("*, NULL AS hidden_action_id").first

        expect(helper.hide_link_text_for(submission)).
          to eq(t("submissions.submission_list_item.actions.default.hidden"))
      end
    end

    context "when `saved_action_id` is not defined on the submission" do
      it "raises an error" do
        submission = build(:submission, :text)

        expect { helper.hide_link_text_for(submission) }.to raise_error(NoMethodError)
      end
    end
  end
end
