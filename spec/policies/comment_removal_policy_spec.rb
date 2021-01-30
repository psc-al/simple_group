RSpec.describe CommentRemovalPolicy do
  describe "relation_scope" do
    context "when the user is an admin" do
      it "returns the relation" do
        user = create(:user, :admin)
        removal = create(:comment_removal, removed_by: user)

        policy = CommentRemovalPolicy.new(user: user)

        expect(policy.apply_scope(CommentRemoval.all, type: :active_record_relation)).
          to match_array([removal])
      end
    end

    context "when the user is a moderator" do
      it "filters the relation to exclude doxx removals unless the user is the remover" do
        user = create(:user, :moderator)
        removal = create(:comment_removal, removed_by: user)
        doxx_removed_by_mod = create(:comment_removal, removed_by: user, reason: :doxxing)
        create(:comment_removal, reason: :doxxing)

        policy = CommentRemovalPolicy.new(user: user)

        expect(policy.apply_scope(CommentRemoval.all, type: :active_record_relation)).
          to match_array([removal, doxx_removed_by_mod])
      end
    end
  end

  describe "#show?" do
    context "when the user is an admin" do
      it "returns true" do
        user = create(:user, :admin)
        removal = create(:comment_removal)
        doxxed = create(:comment_removal, reason: :doxxing)

        expect(CommentRemovalPolicy.new(removal, user: user).show?).to eq(true)
        expect(CommentRemovalPolicy.new(doxxed, user: user).show?).to eq(true)
      end
    end

    context "when the user is a mod" do
      context "when removed for doxxing" do
        it "returns true if the mod removed the comment" do
          user = create(:user, :moderator)
          removal = create(:comment_removal, reason: :doxxing, removed_by: user)

          expect(CommentRemovalPolicy.new(removal, user: user).show?).to eq(true)
        end

        it "returns false if the mod did not remove the comment" do
          user = create(:user, :moderator)
          removal = create(:comment_removal, reason: :doxxing)

          expect(CommentRemovalPolicy.new(removal, user: user).show?).to eq(false)
        end
      end

      context "when not removed for doxxing" do
        it "returns true" do
          user = create(:user, :moderator)
          removal = create(:comment_removal, reason: :spam)

          expect(CommentRemovalPolicy.new(removal, user: user).show?).to eq(true)
        end
      end
    end
  end
end
