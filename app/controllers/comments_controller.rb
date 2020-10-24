class CommentsController < ApplicationController
  before_action :authenticate_user!

  def create
    submission = Submission.visible.friendly.find(params[:submission_short_id])
    @comment = build_comment_for(submission)

    if @comment.save
      Vote.upvote.create!(votable: @comment, user: current_user)
      maybe_create_reply_notification(submission, @comment)
      redirect_path = "#{submission_path(submission.short_id)}##{@comment.short_id}"
      flash = { notice: t(".success") }
    else
      redirect_path = submission_path(params[:submission_short_id])
      flash = { alert: @comment.errors.full_messages.join(",") }
    end

    redirect_to redirect_path, flash
  end

  private

  def build_comment_for(submission)
    authorize!(parent, to: :reply?) if parent.present?
    submission.comments.new(
      body: comment_params[:body],
      user: current_user,
      parent: parent
    )
  end

  def maybe_create_reply_notification(submission, comment)
    if parent.present?
      if current_user.id != parent.user_id
        ThreadReplyNotification.create!(
          recipient_id: parent.user_id,
          in_response_to_comment: parent,
          reply: comment
        )
      end
    elsif current_user.id != submission.user_id
      ThreadReplyNotification.create!(
        recipient_id: submission.user_id,
        reply: comment
      )
    end
  end

  def parent
    @_parent ||= Comment.find(comment_params[:parent_id]) if comment_params[:parent_id].present?
  end

  def comment_params
    params.require(:comment).permit(:body, :parent_id)
  end
end
