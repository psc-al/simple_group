require "rails_helper"

RSpec.describe Domain, type: :model do
  it { should belong_to(:banned_by).class_name("User").optional }
  it { should have_many(:submissions) }

  describe "#banned?" do
    it "is true when `banned_at` is present" do
      expect(build(:domain, banned_at: Time.zone.now).banned?).to eq(true)
    end

    it "is false when `banned_at` is not present" do
      expect(build(:domain, banned_at: nil).banned?).to eq(false)
    end
  end
end
