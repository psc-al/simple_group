module Admin
  class SubmissionRemovalsController < BaseController
    DEFAULT_PAGE = 0
    DEFAULT_PER_PAGE = 25

    def index
      @paginator = ResultsPaginator.new(
        authorized_scope(SubmissionRemoval.includes(:removed_by, submission: :user)),
        pagination_params
      )
    end

    def show
      @removal = SubmissionRemoval.includes(:removed_by, submission: :user).find(params[:id])
      authorize! @removal, to: :show?
    end

    def new
      @submission = Submission.includes(:user).friendly.
        find(submission_removal_params.delete(:submission_short_id))
      @removal = SubmissionRemoval.new(submission_removal_params.merge(submission_id: @submission.id))
    end

    def create
      Submission.friendly.find(submission_removal_params.delete(:submission_short_id)).then do |s|
        s.update!(removed: true)
        SubmissionRemoval.where(submission: s).
          first_or_create!(submission_removal_params.merge(removed_by: current_user))
      end

      redirect_to admin_submission_removals_path, notice: t(".success")
    end

    def destroy
      removal = SubmissionRemoval.includes(:submission).find(params[:id])
      removal.submission.update!(removed: false)
      removal.destroy!

      redirect_to admin_submission_removals_path, notice: t(".success")
    end

    private

    def pagination_params
      {
        page: params.fetch(:page, DEFAULT_PAGE),
        per_page: params.fetch(:per_page, DEFAULT_PER_PAGE),
        order: { created_at: :desc }
      }
    end

    def submission_removal_params
      @_submission_removal_params ||= params.
        require(:submission_removal).
        permit(:submission_short_id, :reason, :details)
    end
  end
end
