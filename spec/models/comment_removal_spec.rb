RSpec.describe CommentRemoval, type: :model do
  it { should belong_to(:comment) }
  it { should belong_to(:removed_by).class_name("User") }
end
