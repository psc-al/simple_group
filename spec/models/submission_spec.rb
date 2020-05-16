RSpec.describe Submission, type: :model do
  it { should belong_to(:user) }
  it { should belong_to(:domain).optional }

  describe "#before_create" do
    it "sets its short id" do
      submission = build(:submission, :url)

      expect(submission.short_id).to be_nil

      submission.save!

      expect(submission.short_id).not_to be_nil
      expect(submission.short_id.length).to eq(8)
    end
  end
end
