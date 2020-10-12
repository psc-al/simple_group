RSpec.describe SubmissionAction, type: :model do
  it do
    should belong_to(:submission).
      with_foreign_key(:submission_short_id).
      with_primary_key(:short_id)
  end

  it { should belong_to(:user) }
end
