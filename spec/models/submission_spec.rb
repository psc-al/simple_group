RSpec.describe Submission, type: :model do
  it { should belong_to(:user) }
  it { should belong_to(:domain).optional }
  it { should have_many(:submission_tags) }
  it { should have_many(:tags).through(:submission_tags) }
  it { should have_many(:comments) }
  it { should have_many(:votes) }

  describe ".short_id_prefix" do
    it "is :s_" do
      expect(Submission.short_id_prefix).to eq(:s_)
    end
  end

  describe "#before_create" do
    it "sets its short id to a random 8-character base-36 string prefixed with s_" do
      submission = build(:submission, :url)

      expect(submission.short_id).to be_nil

      submission.save!

      expect(submission.short_id).not_to be_nil
      expect(submission.short_id).to start_with("s_")
      expect(submission.short_id[2..-1].length).to eq(8)
    end
  end
end
