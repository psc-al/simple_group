RSpec.describe "user comments on submission" do
  let(:submission) { create(:submission, :text) }
  let(:page) { ViewSubmissionPage.new }
  let(:user) { create(:user) }

  it "can hide a comment and its replies", js: true do
    comment = create(:comment, submission: submission, user: user, body: "a nice comment")
    child = create(:comment, parent: comment, submission: submission, user: user, body: "a nice child comment")

    page.visit(submission, as: user)

    expect(page).to have_comment("a nice comment")
    expect(page).to have_comment_reply(comment, child)

    page.hide_comment(comment)

    expect(page).not_to have_comment("a nice comment")
    expect(page).not_to have_comment_reply(comment, child)
  end

  context "when the user is logged in" do
    it "can leave a comment on the submission that gets automagically upvoted for them" do
      page.visit(submission, as: user)

      expect { page.leave_comment("jet fuel can't melt dank memes") }.
        to change(Comment, :count).from(0).to(1)
      expect(page).to have_comment("jet fuel can't melt dank memes")
      expect(submission.comments.count).to eq(1)

      comment = Comment.first

      expect(comment.submission_id).to eq(submission.id)
      expect(comment.body).to eq("jet fuel can't melt dank memes")
      expect(comment.user_id).to eq(user.id)
      expect(comment.votes.upvote.count).to eq(1)
      expect(comment.votes.upvote.first.user_id).to eq(user.id)
    end

    it "can reply to a comment, and the reply gets automagically upvoted for them", js: true do
      parent = create(:comment, submission: submission, user: user, body: "a nice comment")

      page.visit(submission, as: user)

      expect { page.reply_to_comment(parent, "such a nice reply") }.
        to change(Comment, :count).from(1).to(2)
      expect(submission.comments.count).to eq(2)
      expect(page).to have_comment("a nice comment")

      new_comment = Comment.where.not(id: parent.id).first

      expect(new_comment.submission_id).to eq(submission.id)
      expect(new_comment.body).to eq("such a nice reply")
      expect(new_comment.user_id).to eq(user.id)
      expect(new_comment.parent_id).to eq(parent.id)
      expect(new_comment.votes.upvote.count).to eq(1)
      expect(new_comment.votes.upvote.first.user_id).to eq(user.id)
      expect(page).to have_comment_reply(parent, new_comment)
    end

    it "can re-hide the reply box", js: true do
      parent = create(:comment, submission: submission, user: user, body: "a nice comment")

      page.visit(submission, as: user)

      expect(page).not_to have_open_reply_box_for(parent)

      page.open_comment_reply_box(parent)

      expect(page).to have_open_reply_box_for(parent)

      page.close_comment_reply_box(parent)

      expect(page).not_to have_open_reply_box_for(parent)
    end
  end

  context "when the user is not signed in" do
    it "redirects them when they try to comment" do
      page.visit(submission, as: nil)

      page.leave_comment("rain drop drop top")

      expect(page).to have_current_path(new_user_session_path)
    end

    it "redirects them when they try to reply to a comment", js: true do
      parent = create(:comment, submission: submission, user: user, body: "a nice comment")
      page.visit(submission, as: nil)

      page.reply_to_comment(parent, "such a nice reply")

      expect(page).to have_current_path(new_user_session_path)
    end
  end
end
