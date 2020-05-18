class CommentsController < ApplicationController
  before_action :authenticate_user!

  def create
    submission = Submission.friendly.find(params[:submission_short_id])
    @comment = build_comment_for(submission)

    if @comment.save
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
    submission.comments.new(
      body: comment_params[:body],
      user: current_user,
      parent_id: comment_params[:parent_id]
    )
  end

  def comment_params
    params.require(:comment).permit(:body, :parent_id)
  end
end
