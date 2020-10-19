RSpec.describe SubmissionRemovalPolicy do
  describe "relation_scope" do
    context "when the user is an admin" do
      it "returns the relation" do
        user = create(:user, :admin)
        removal = create(:submission_removal, removed_by: user)

        policy = SubmissionRemovalPolicy.new(user: user)

        expect(policy.apply_scope(SubmissionRemoval.all, type: :active_record_relation)).
          to match_array([removal])
      end
    end

    context "when the user is a moderator" do
      it "filters the relation to exclude doxx removals unless the user is the remover" do
        user = create(:user, :moderator)
        removal = create(:submission_removal, removed_by: user)
        doxx_removed_by_mod = create(:submission_removal, removed_by: user, reason: :doxxing)
        create(:submission_removal, reason: :doxxing)

        policy = SubmissionRemovalPolicy.new(user: user)

        expect(policy.apply_scope(SubmissionRemoval.all, type: :active_record_relation)).
          to match_array([removal, doxx_removed_by_mod])
      end
    end
  end

  describe "#show?" do
    context "when the user is an admin" do
      it "returns true" do
        user = create(:user, :admin)
        removal = create(:submission_removal)
        doxxed = create(:submission_removal, reason: :doxxing)

        expect(SubmissionRemovalPolicy.new(removal, user: user).show?).to eq(true)
        expect(SubmissionRemovalPolicy.new(doxxed, user: user).show?).to eq(true)
      end
    end

    context "when the user is a mod" do
      context "when removed for doxxing" do
        it "returns true if the mod removed the submission" do
          user = create(:user, :moderator)
          removal = create(:submission_removal, reason: :doxxing, removed_by: user)

          expect(SubmissionRemovalPolicy.new(removal, user: user).show?).to eq(true)
        end

        it "returns false if the mod did not remove the submission" do
          user = create(:user, :moderator)
          removal = create(:submission_removal, reason: :doxxing)

          expect(SubmissionRemovalPolicy.new(removal, user: user).show?).to eq(false)
        end
      end

      context "when not removed for doxxing" do
        it "returns true" do
          user = create(:user, :moderator)
          removal = create(:submission_removal, reason: :spam)

          expect(SubmissionRemovalPolicy.new(removal, user: user).show?).to eq(true)
        end
      end
    end
  end
end
