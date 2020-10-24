module Admin
  class CommentRemovalsController < BaseController
    DEFAULT_PAGE = 0
    DEFAULT_PER_PAGE = 25

    def index
      @paginator = ResultsPaginator.new(
        authorized_scope(CommentRemoval.includes(:removed_by, comment: :user)),
        pagination_params
      )
    end

    def show
      @removal = CommentRemoval.includes(:removed_by, comment: [:user, :submission]).find(params[:id])
      authorize! @removal, to: :show?
    end

    def new
      @comment = Comment.includes(:user).find(comment_removal_params.delete(:comment_id))
      @removal = CommentRemoval.new(comment_removal_params.merge(comment_id: @comment.id))
    end

    def create
      Comment.find(comment_removal_params.delete(:comment_id)).then do |c|
        c.update!(removed: true)
        CommentRemoval.where(comment: c).
          first_or_create!(comment_removal_params.merge(removed_by: current_user))
      end

      redirect_to admin_comment_removals_path, notice: t(".success")
    end

    def destroy
      removal = CommentRemoval.includes(:comment).find(params[:id])
      removal.comment.update!(removed: false)
      removal.destroy!

      redirect_to admin_comment_removals_path, notice: t(".success")
    end

    private

    def pagination_params
      {
        page: params.fetch(:page, DEFAULT_PAGE),
        per_page: params.fetch(:per_page, DEFAULT_PER_PAGE),
        order: { created_at: :desc }
      }
    end

    def comment_removal_params
      @_comment_removal_params ||= params.
        require(:comment_removal).
        permit(:comment_id, :reason, :details)
    end
  end
end
