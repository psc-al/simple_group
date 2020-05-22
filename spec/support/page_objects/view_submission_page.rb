require "support/page_objects/page_base"
require "support/page_objects/shared_components/submission_actions_component"

class ViewSubmissionPage < PageBase
  include SubmissionActionsComponent

  def visit(submission, as:)
    login_as(as) if as.present?
    super(submission_path(submission.id))
    self
  end

  def leave_comment(body)
    within("form#new_comment") do
      fill_in :comment_body, with: body
      click_on t("helpers.submit.comment.create")
    end
  end

  def leave_comment_reply(comment, reply_body)
    within find("##{comment.short_id}") do
      leave_comment(reply_body)
    end
  end

  def reply_to_comment(comment, reply_body)
    open_comment_reply_box(comment)
    leave_comment_reply(comment, reply_body)
  end

  def open_comment_reply_box(comment)
    within find("##{comment.short_id}") do
      click_on t("comments.comment.reply")
    end
  end

  def close_comment_reply_box(comment)
    within find("##{comment.short_id}") do
      click_on t("comments.form.cancel")
    end
  end

  def hide_comment(comment)
    within find("##{comment.short_id}") do
      first(".hide-comment").click
    end
  end

  def upvote_comment(comment)
    vote_on_comment(comment, :up)
  end

  def downvote_comment(comment)
    vote_on_comment(comment, :down)
  end

  def has_correct_submission_link?(submission)
    url = submission.url.presence || submission_path(submission.short_id)

    within find(".submission-link") do
      has_link?(submission.title, href: url)
    end
  end

  def has_authored_by?(user)
    within find(".submission-line2") do
      has_css?(".submission-info", text: t("submissions.submission_list_item.authored_by")) &&
        has_css?(".submission-user a", text: user.username)
    end
  end

  def has_submitted_by?(user)
    within find(".submission-line2") do
      has_css?(".submission-info", text: t("submissions.submission_list_item.submitted_by")) &&
        has_css?(".submission-user a", text: user.username)
    end
  end

  def has_plain_text_submission_body?(body)
    within find(".submission-body") do
      has_css?("p", text: body)
    end
  end

  def has_tag?(tag)
    has_css?(".tag_#{tag.kind}", text: tag.id)
  end

  def has_comment?(body)
    has_css?(".comment-body", text: body, wait: 0)
  end

  def has_comment_reply?(parent, reply)
    path = "##{parent.short_id} .comment-content .comment-replies ##{reply.short_id}"
    has_css?(path, wait: 0) && within(find(path)) { has_comment?(reply.body) }
  end

  def has_open_reply_box_for?(comment)
    within find("##{comment.short_id} .comment-content") do
      has_css?("#reply_#{comment.short_id}")
    end
  end

  def has_upvoted_comment?(comment)
    has_comment_vote?(comment, :up)
  end

  def has_downvoted_comment?(comment)
    has_comment_vote?(comment, :down)
  end

  private

  def vote_on_comment(comment, direction)
    find("##{direction}vote_#{comment.short_id}").click
    self
  end

  def has_comment_vote?(comment, direction)
    within find("##{comment.short_id}") do
      has_css?(".#{direction}voted", wait: 1.5)
    end
  end
end
