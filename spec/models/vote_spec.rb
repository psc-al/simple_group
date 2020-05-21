RSpec.describe Vote, type: :model do
  describe "associations" do
    before do
      subject { build_stubbed(:upvote, :submission) }
      # why do we need to do this? because `shoulda` apparently
      # sets any given association to `nil` when testing to check if
      # a model has it (to raise validation errors). this ends
      # up also breaking our defined model validations which are dependent
      # on these associations being present, and so an error related to
      # those validations gets raised and breaks the test.

      # rubocop:disable RSpec/SubjectStub
      allow(subject).to receive(:votable_type).and_return("Submission")
      # rubocop:enable RSpec/SubjectStub
    end

    it { should belong_to(:votable) }
    it { should belong_to(:user) }
    it { should define_enum_for(:kind).with_values(upvote: 0, downvote: 1) }
  end

  it do
    should define_enum_for(:downvote_reason).with_values(
      off_topic: 0,
      incorrect: 5,
      spam: 10,
      mean: 15,
      unhelpful: 20,
      troll: 25,
      broken_link: 30,
      repost: 35
    )
  end

  describe "validations" do
    it "validates that the vote is for the proper votable type" do
      vote = build(:upvote, votable: build(:user))

      expect(vote).not_to be_valid
      expect(vote.errors[:votable_type]).to include(
        I18n.t("votes.errors.unsupported_votable_type", type: "users")
      )
    end

    describe "downvote reason" do
      context "when the vote is an upvote" do
        it "does not allow a downvote reason" do
          submission_upvote = build(:upvote, :submission, downvote_reason: :off_topic)

          expect(submission_upvote).not_to be_valid
          expect(submission_upvote.errors[:downvote_reason]).to include(
            I18n.t("votes.errors.downvote_reason_for_upvote")
          )

          comment_upvote = build(:upvote, :comment, downvote_reason: :off_topic)

          expect(comment_upvote).not_to be_valid
          expect(comment_upvote.errors[:downvote_reason]).to include(
            I18n.t("votes.errors.downvote_reason_for_upvote")
          )
        end
      end

      context "when the vote is a downvote" do
        it "requires a downvote reason" do
          submission_downvote = build(:downvote, :submission, downvote_reason: nil)

          expect(submission_downvote).not_to be_valid
          expect(submission_downvote.errors[:downvote_reason]).to include(
            I18n.t("votes.errors.missing_downvote_reason")
          )

          comment_downvote = build(:downvote, :comment, downvote_reason: nil)

          expect(comment_downvote).not_to be_valid
          expect(comment_downvote.errors[:downvote_reason]).to include(
            I18n.t("votes.errors.missing_downvote_reason")
          )
        end

        it "requires the correct downvote reason for the votable type" do
          submission_downvote = build(:downvote, :submission, downvote_reason: :mean)

          expect(submission_downvote).not_to be_valid
          expect(submission_downvote.errors[:downvote_reason]).to include(
            I18n.t("votes.errors.invalid_submission_downvote_reason")
          )

          comment_downvote = build(:downvote, :comment, downvote_reason: :broken_link)

          expect(comment_downvote).not_to be_valid
          expect(comment_downvote.errors[:downvote_reason]).to include(
            I18n.t("votes.errors.invalid_comment_downvote_reason")
          )
        end
      end
    end
  end
end
