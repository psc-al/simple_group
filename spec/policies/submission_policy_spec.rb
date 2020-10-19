RSpec.describe SubmissionPolicy do
  describe "relation_scope" do
    context "when the user is nil" do
      it "returns only the submissions that haven't been removed" do
        s1 = create(:submission)
        create(:submission, :removed)

        policy = SubmissionPolicy.new(user: nil)

        expect(policy.apply_scope(FlattenedSubmission.all, type: :active_record_relation).pluck(:id)).
          to match_array([s1.id])
      end
    end

    context "when the user is an admin" do
      it "returns the relation" do
        admin = create(:user, :admin)
        s1 = create(:submission)
        s2 = create(:submission, :removed)

        policy = SubmissionPolicy.new(nil, user: admin)

        expect(policy.apply_scope(FlattenedSubmission.all, type: :active_record_relation).pluck(:id)).
          to match_array([s1.id, s2.id])
      end
    end

    context "when the user is a moderator" do
      it "returns visible submissions and submissions authored / removed by the user" do
        mod = create(:user, :moderator)
        s1 = create(:submission)
        create(:submission, :removed)
        s3 = create(:submission, :removed, removed_by: mod)

        policy = SubmissionPolicy.new(nil, user: mod)

        expect(policy.apply_scope(FlattenedSubmission.all, type: :active_record_relation).pluck(:id)).
          to match_array([s1.id, s3.id])
      end
    end

    context "when the user is a member" do
      it "returns visible submissions and submissions authored by the user" do
        user = create(:user, :member)
        s1 = create(:submission)
        s2 = create(:submission, user: user)
        s3 = create(:submission, :removed, user: user)
        create(:submission, :removed)

        policy = SubmissionPolicy.new(nil, user: user)

        expect(policy.apply_scope(FlattenedSubmission.all, type: :active_record_relation).pluck(:id)).
          to match_array([s1.id, s2.id, s3.id])
      end
    end
  end

  describe "#show?" do
    context "when the submission has been removed" do
      context "when the user is an admin" do
        it "returns true" do
          admin = build(:user, :admin)
          submission = build(:submission, :removed)

          expect(SubmissionPolicy.new(submission, user: admin).show?).to eq(true)
        end
      end

      context "when the user is a moderator and removed the submission" do
        it "returns true for regular and doxxing removals" do
          mod = create(:user, :moderator)
          submission = build(:submission, :removed, removed_by: mod)
          submission_doxxing = build(:submission, :removed, removed_by: mod, reason: :doxxing)

          expect(SubmissionPolicy.new(submission, user: mod).show?).to eq(true)
          expect(SubmissionPolicy.new(submission_doxxing, user: mod).show?).to eq(true)
        end
      end

      context "when the user is a moderator and is not the one who removed the submission" do
        context "when the submission was removed for doxxing" do
          it "returns false" do
            mod = create(:user, :moderator)
            submission = build(:submission, :removed, reason: :doxxing)

            expect(SubmissionPolicy.new(submission, user: mod).show?).to eq(false)
          end
        end

        context "when the submission was not removed for doxxing" do
          it "returns true" do
            mod = create(:user, :moderator)
            submission = build(:submission, :removed, reason: :spam)

            expect(SubmissionPolicy.new(submission, user: mod).show?).to eq(true)
          end
        end
      end

      context "when the user is the author" do
        it "returns true" do
          user = create(:user)
          submission = create(:submission, :removed, user: user)

          expect(SubmissionPolicy.new(submission, user: user).show?).to eq(true)
        end
      end

      context "when the user is not an admin, moderator, or the author" do
        it "returns false" do
          user = create(:user)
          submission = create(:submission, :removed)

          expect(SubmissionPolicy.new(submission, user: user).show?).to eq(false)
        end
      end
    end

    context "when submission has not been removed" do
      it "returns true" do
        user = create(:user)
        submission = create(:submission, user: user)

        expect(SubmissionPolicy.new(submission, user: user).show?).to eq(true)
      end
    end
  end

  describe "#edit?" do
    context "when the user is nil" do
      it "returns false" do
        submission = build(:submission)

        expect(SubmissionPolicy.new(submission, user: nil).edit?).to eq(false)
      end
    end

    context "when the submission has been removed" do
      context "when the user is the author" do
        it "returns false" do
          user = create(:user)
          submission = create(:submission, :removed, user: user)

          expect(SubmissionPolicy.new(submission, user: user).edit?).to eq(false)
        end
      end

      context "when the user is an admin" do
        it "returns true" do
          admin = create(:user, :admin)
          submission = create(:submission, :removed, user: admin)

          expect(SubmissionPolicy.new(submission, user: admin).edit?).to eq(true)
        end
      end

      context "when the user is a moderator and removed the submission" do
        it "returns true" do
          mod = create(:user, :moderator)
          submission = create(:submission, :removed, user: mod, removed_by: mod)

          expect(SubmissionPolicy.new(submission, user: mod).edit?).to eq(true)
        end
      end

      context "when the user is a moderator and is not the one who removed the submission" do
        it "returns false" do
          mod = create(:user, :moderator)
          submission = create(:submission, :removed, user: mod)

          expect(SubmissionPolicy.new(submission, user: mod).edit?).to eq(false)
        end
      end
    end

    context "when the submission has not been removed" do
      context "when the user is the author" do
        it "returns true" do
          user = create(:user)
          submission = create(:submission, user: user)

          expect(SubmissionPolicy.new(submission, user: user).edit?).to eq(true)
        end
      end

      context "when the user is an admin" do
        it "returns true" do
          admin = create(:user, :admin)
          submission = create(:submission)

          expect(SubmissionPolicy.new(submission, user: admin).edit?).to eq(true)
        end
      end

      context "when the user is a moderator" do
        it "returns true" do
          mod = create(:user, :moderator)
          submission = create(:submission)

          expect(SubmissionPolicy.new(submission, user: mod).edit?).to eq(true)
        end
      end
    end
  end

  describe "#update?" do
    context "when the user is nil" do
      it "returns false" do
        submission = build(:submission)

        expect(SubmissionPolicy.new(submission, user: nil).update?).to eq(false)
      end
    end

    context "when the submission has been removed" do
      context "when the user is the author" do
        it "returns false" do
          user = create(:user)
          submission = create(:submission, :removed, user: user)

          expect(SubmissionPolicy.new(submission, user: user).update?).to eq(false)
        end
      end

      context "when the user is an admin" do
        it "returns true" do
          admin = create(:user, :admin)
          submission = create(:submission, :removed, user: admin)

          expect(SubmissionPolicy.new(submission, user: admin).update?).to eq(true)
        end
      end

      context "when the user is a moderator and removed the submission" do
        it "returns true" do
          mod = create(:user, :moderator)
          submission = create(:submission, :removed, user: mod, removed_by: mod)

          expect(SubmissionPolicy.new(submission, user: mod).update?).to eq(true)
        end
      end

      context "when the user is a moderator and is not the one who removed the submission" do
        it "returns false" do
          mod = create(:user, :moderator)
          submission = create(:submission, :removed, user: mod)

          expect(SubmissionPolicy.new(submission, user: mod).update?).to eq(false)
        end
      end
    end

    context "when the submission has not been removed" do
      context "when the user is the author" do
        it "returns true" do
          user = create(:user)
          submission = create(:submission, user: user)

          expect(SubmissionPolicy.new(submission, user: user).update?).to eq(true)
        end
      end

      context "when the user is an admin" do
        it "returns true" do
          admin = create(:user, :admin)
          submission = create(:submission)

          expect(SubmissionPolicy.new(submission, user: admin).update?).to eq(true)
        end
      end

      context "when the user is a moderator" do
        it "returns true" do
          mod = create(:user, :moderator)
          submission = create(:submission)

          expect(SubmissionPolicy.new(submission, user: mod).update?).to eq(true)
        end
      end
    end
  end

  describe "#hard_delete?" do
    context "when the user is nil" do
      it "returns false" do
        submission = create(:submission)

        expect(SubmissionPolicy.new(submission, user: nil).hard_delete?).to eq(false)
      end
    end

    context "when the user is the author and there are no comments" do
      it "returns true" do
        user = create(:user)
        submission = create(:submission, user: user)

        expect(SubmissionPolicy.new(submission, user: user).hard_delete?).to eq(true)
      end
    end

    # Once the thread has comments, allowing them to hard to delete submissions can
    # screw things up for other users.
    context "when the user is the author and there are comments" do
      it "returns false" do
        user = create(:user)
        submission = create(:submission, :with_comments, user: user)

        expect(SubmissionPolicy.new(submission, user: user).hard_delete?).to eq(false)
      end
    end

    context "when the user is an admin" do
      it "returns true" do
        admin = create(:user, :admin)
        submission = create(:submission)

        expect(SubmissionPolicy.new(submission, user: admin).hard_delete?).to eq(true)
      end
    end

    context "when the user is a moderator" do
      it "returns false" do
        mod = create(:user, :moderator)
        submission = create(:submission)

        expect(SubmissionPolicy.new(submission, user: mod).hard_delete?).to eq(false)
      end
    end
  end
end
