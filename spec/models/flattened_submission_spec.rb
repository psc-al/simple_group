RSpec.describe FlattenedSubmission, type: :model do
  it { should have_many(:submission_tags).with_primary_key(:id).with_foreign_key(:submission_id) }
  it { should have_many(:tags).through(:submission_tags) }

  it do
    should have_many(:flattened_comments).class_name("FlattenedComment").
      with_primary_key(:id).
      with_foreign_key(:submission_id)
  end

  it "is a flat view of submissions" do
    user = create(:user)
    text_submission = create(
      :submission,
      :with_comments,
      :text,
      title: "super nice title",
      body: "super nice body",
      user: user,
      original_author: true,
      created_at: Time.zone.local(2020),
      num_comments: 3
    )
    create_list(:upvote, 5, votable: text_submission)
    create_list(:downvote, 3, votable: text_submission)
    url_submission = create(
      :submission,
      :with_comments,
      :url,
      title: "super nice title",
      url: "https://foo.com",
      user: user,
      original_author: false,
      created_at: Time.zone.local(2020, 1, 15),
      num_comments: 5
    )
    create_list(:upvote, 3, votable: url_submission)
    create_list(:downvote, 5, votable: url_submission)

    expect(FlattenedSubmission.count).to eq(2)

    flat_text_submission = FlattenedSubmission.find(text_submission.id)
    flat_url_submission = FlattenedSubmission.find(url_submission.id)

    expect(flat_text_submission.id).to eq(text_submission.id)
    expect(flat_text_submission.short_id).to eq(text_submission.short_id)
    expect(flat_text_submission.title).to eq(text_submission.title)
    expect(flat_text_submission.url).to be_nil
    expect(flat_text_submission.domain_name).to be_nil
    expect(flat_text_submission.body).to eq(text_submission.body)
    expect(flat_text_submission.submitter_username).to eq(user.username)
    expect(flat_text_submission).to be_original_author
    expect(flat_text_submission.created_at).to eq(text_submission.created_at)
    expect(flat_text_submission.comment_count).to eq(3)
    expect(flat_text_submission.score).to eq(2)

    expect(flat_url_submission.id).to eq(url_submission.id)
    expect(flat_url_submission.short_id).to eq(url_submission.short_id)
    expect(flat_url_submission.title).to eq(url_submission.title)
    expect(flat_url_submission.url).to eq(url_submission.url)
    expect(flat_url_submission.domain_name).to eq(url_submission.domain.name)
    expect(flat_url_submission.body).to be_nil
    expect(flat_url_submission.submitter_username).to eq(user.username)
    expect(flat_url_submission).not_to be_original_author
    expect(flat_url_submission.created_at).to eq(url_submission.created_at)
    expect(flat_url_submission.comment_count).to eq(5)
    expect(flat_url_submission.score).to eq(-2)
  end
end
