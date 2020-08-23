RSpec.describe User do
  it { should define_enum_for(:role).with_values(member: 0, moderator: 10, admin: 20, deactivated: 100) }
  it { should have_many(:submissions) }
  it { should have_many(:submission_actions) }
  it { should have_many(:comments) }
  it { should have_many(:votes) }
  it { should have_many(:sent_user_invitations).class_name(:UserInvitation).with_foreign_key(:sender_id) }

  it do
    should have_one(:received_user_invitation).
      class_name(:UserInvitation).with_foreign_key(:recipient_id).required(false)
  end

  describe "#update_last_submission_at!" do
    it "updates the last submission time to the current time" do
      now = Time.zone.now
      travel_to now do
        user = create(:user)

        expect(user.last_submission_at).to be_nil

        user.update_last_submission_at!

        # this is a hack sort of because the database column doesn't
        # care about microseconds
        expect(user.last_submission_at).to eq(now.change(usec: 0))
      end
    end
  end

  describe "#minutes_until_next_submission" do
    it "is 0.0 if `last_submission_at` is `nil`" do
      user = build(:user, last_submission_at: nil)

      expect(user.minutes_until_next_submission).to eq(0.0)
    end

    it "is 0.0 if the current time exceeds 10 minutes since the last submission" do
      now = Time.zone.now
      user = build(:user, last_submission_at: now - 20.minutes)
      travel_to now do
        expect(user.minutes_until_next_submission).to eq(0.0)
      end
    end

    it "10min since last submission MINUS current time in min when current time is within 10min of last submission" do
      now = Time.zone.now.change(usec: 0)
      user = build(:user, last_submission_at: now)
      travel_to now + 7.minutes do
        # it's been 7 minutes since the last submission, so they
        # can submit again in 3 minutes
        expect(user.minutes_until_next_submission).to eq(3.0)
      end
    end
  end

  describe "#can_invite?" do
    around do |example|
      now = Time.zone.now
      travel_to now do
        example.run
      end
    end

    context "when the user is an admin" do
      it "can invite, regardless of number of daily invites" do
        admin = create(:user, :admin)
        create_list(:user_invitation, 10, sender: admin)

        expect(admin.can_invite?).to eq(true)
      end
    end

    context "when the user is not an admin" do
      it "is true when the daily invite max hasn't been met" do
        user = create(:user)
        create_list(:user_invitation, 3, sender: user)

        expect(user.can_invite?).to eq(true)
      end

      it "is false when the daily invite max has been met" do
        user = create(:user)
        create_list(:user_invitation, 10, sender: user)

        expect(user.can_invite?).to eq(false)
      end
    end
  end
end
