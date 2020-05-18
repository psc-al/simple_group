RSpec.describe User do
  it { should define_enum_for(:role).with_values(member: 0, moderator: 10, admin: 20) }
  it { should have_many(:submissions) }
  it { should have_many(:submission_actions) }
  it { should have_many(:comments) }

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
end
