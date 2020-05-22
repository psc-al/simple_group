RSpec.describe FlattenedComment, type: :model do
  it "is a flat view of comments" do
    user = create(:user)
    submission = create(:submission, :text)

    parent = create(:comment, user: user, submission: submission, body: "parent body")
    child = create(
      :comment,
      user: user,
      submission: submission,
      body: "child comment body",
      parent: parent
    )
    create_list(:upvote, 5, votable: parent)
    create_list(:downvote, 3, votable: parent)
    create_list(:upvote, 3, votable: child)
    create_list(:downvote, 5, votable: child)

    expect(FlattenedComment.count).to eq(2)

    flattened_parent = FlattenedComment.find(parent.id)
    flattened_child = FlattenedComment.find(child.id)

    expect(flattened_parent.id).to eq(parent.id)
    expect(flattened_parent.short_id).to eq(parent.short_id)
    expect(flattened_parent.submission_id).to eq(parent.submission_id)
    expect(flattened_parent.body).to eq(parent.body)
    expect(flattened_parent.created_at).to eq(parent.created_at)
    expect(flattened_parent.updated_at).to eq(parent.updated_at)
    expect(flattened_parent.commenter).to eq(user.username)
    expect(flattened_parent.parent_id).to be_nil
    expect(flattened_parent.score).to eq(2)

    expect(flattened_child.id).to eq(child.id)
    expect(flattened_child.short_id).to eq(child.short_id)
    expect(flattened_child.submission_id).to eq(child.submission_id)
    expect(flattened_child.body).to eq(child.body)
    expect(flattened_child.created_at).to eq(child.created_at)
    expect(flattened_child.updated_at).to eq(child.updated_at)
    expect(flattened_child.commenter).to eq(user.username)
    expect(flattened_child.parent_id).to eq(parent.id)
    expect(flattened_child.score).to eq(-2)
  end
end
