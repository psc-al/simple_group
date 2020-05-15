RSpec.describe SubmissionTag, type: :model do
  it { should belong_to(:submission) }
  it { should belong_to(:tag) }
end
