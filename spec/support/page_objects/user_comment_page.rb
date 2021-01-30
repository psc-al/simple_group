require "support/page_objects/page_base"

class UserCommentPage < PageBase
  def initialize(user)
    @user = user
  end

  def visit(as: nil)
    login_as(as) if as.present?
    super user_comments_path(user.username)
  end

  def has_comment_row?(comment)
    has_css?(".comment-container", id: comment.short_id)
  end

  def has_comment_link_for?(comment)
    has_link? "link", href: submission_path(comment.submission_id, anchor: comment.short_id)
  end

  private

  attr_reader :user
end
