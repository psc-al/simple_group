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

  describe "validations" do
    it "validates that the vote is for the proper votable type" do
      vote = build(:upvote, votable: build(:user))

      expect(vote).not_to be_valid
      expect(vote.errors[:votable_type]).to include(
        I18n.t("votes.errors.unsupported_votable_type", type: "users")
      )
    end
  end
end
