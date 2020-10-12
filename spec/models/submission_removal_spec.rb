RSpec.describe SubmissionRemoval, type: :model do
  it { should belong_to(:submission) }
  it { should belong_to(:removed_by).class_name(:User) }
end
