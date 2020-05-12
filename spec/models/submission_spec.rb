RSpec.describe Submission, type: :model do
  it { should belong_to(:user) }
  it { should belong_to(:domain).optional }
end
