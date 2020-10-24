RSpec.describe CommentPolicy do
  describe "relation_scope" do
    context "when the user is nil" do
      it "returns only the comments that haven't been removed" do
        s1 = create(:comment)
        create(:comment, :removed)

        policy = CommentPolicy.new(user: nil)

        expect(policy.apply_scope(FlattenedComment.all, type: :active_record_relation).pluck(:id)).
          to match_array([s1.id])
      end
    end

    context "when the user is an admin" do
      it "returns the relation" do
        admin = create(:user, :admin)
        s1 = create(:comment)
        s2 = create(:comment, :removed)

        policy = CommentPolicy.new(nil, user: admin)

        expect(policy.apply_scope(FlattenedComment.all, type: :active_record_relation).pluck(:id)).
          to match_array([s1.id, s2.id])
      end
    end

    context "when the user is a moderator" do
      it "returns visible comments and comments authored / removed by the user" do
        mod = create(:user, :moderator)
        s1 = create(:comment)
        create(:comment, :removed)
        s3 = create(:comment, :removed, removed_by: mod)

        policy = CommentPolicy.new(nil, user: mod)

        expect(policy.apply_scope(FlattenedComment.all, type: :active_record_relation).pluck(:id)).
          to match_array([s1.id, s3.id])
      end
    end

    context "when the user is a member" do
      it "returns visible comments and comments authored by the user" do
        user = create(:user, :member)
        s1 = create(:comment)
        s2 = create(:comment, user: user)
        s3 = create(:comment, :removed, user: user)
        create(:comment, :removed)

        policy = CommentPolicy.new(nil, user: user)

        expect(policy.apply_scope(FlattenedComment.all, type: :active_record_relation).pluck(:id)).
          to match_array([s1.id, s2.id, s3.id])
      end
    end
  end

  describe "#remove?" do
    context "when the user is nil" do
      it "returns false" do
        policy = CommentPolicy.new(build(:comment), user: nil)

        expect(policy.remove?).to eq(false)
      end
    end

    context "when the user is not a moderator or admin" do
      it "returns false" do
        policy = CommentPolicy.new(build(:comment), user: build(:user))

        expect(policy.remove?).to eq(false)
      end
    end

    context "when the user is an admin" do
      it "returns true" do
        policy = CommentPolicy.new(build(:comment), user: build(:user, :admin))

        expect(policy.remove?).to eq(true)
      end
    end

    context "when the user is a moderator" do
      it "returns true" do
        policy = CommentPolicy.new(build(:comment), user: build(:user, :moderator))

        expect(policy.remove?).to eq(true)
      end
    end
  end

  describe "#reply?" do
    context "when the user is nil" do
      it "returns false" do
        policy = CommentPolicy.new(build(:comment), user: nil)

        expect(policy.reply?).to eq(false)
      end
    end

    context "when the comment has been removed" do
      it "returns false" do
        policy = CommentPolicy.new(build(:comment, :removed), user: build(:user))

        expect(policy.reply?).to eq(false)
      end
    end

    context "when the user is present and the comment has not been removed" do
      it "returns true" do
        policy = CommentPolicy.new(build(:comment), user: build(:user))

        expect(policy.reply?).to eq(true)
      end
    end
  end
end
