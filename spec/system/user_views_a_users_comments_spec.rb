RSpec.describe "User views a user's comments" do
  it "sees the user's comments with latest comments displayed first" do
    user = create(:user)
    comments = create_list(:comment, 3, user: user)

    page = UserCommentPage.new(user)

    page.visit

    comments.each do |comment|
      expect(page).to have_comment_row(comment)
    end
  end
end
