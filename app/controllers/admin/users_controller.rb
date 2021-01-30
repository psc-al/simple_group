module Admin
  class UsersController < BaseController
    DEFAULT_PAGE = 0
    DEFAULT_PER_PAGE = 20

    def index
      @paginator = ResultsPaginator.new(user_relation, pagination_params)
    end

    def edit
      @user = User.find(params[:id])
      @ban_form = BanUserForm.new({})
    end

    def show
      @user = User.find(params[:id])
    end

    def update
      @user = User.find(params[:id])
      @ban_form = BanUserForm.new(ban_user_params)
      @user.update!(@ban_form.to_attributes_hash.merge(banned_by: current_user, unbanned_at: nil))

      redirect_to admin_users_path, notice: "#{@user.username} has been banned."
    end

    def unban
      @user = User.find(params[:id])

      @user.update!(unbanned_at: DateTime.current)

      redirect_to admin_users_path, notice: "#{@user.username} has been unbanned."
    end

    def user_relation
      User.
        include_submission_counts_and_karma.
        include_comment_counts_and_karma.
        select(%{
        users.*,
        COALESCE(scs.submission_count, 0) AS submission_count,
        COALESCE(scs.submission_karma, 0) AS submission_karma,
        COALESCE(ccs.comment_count, 0) AS comment_count,
        COALESCE(ccs.comment_karma, 0) AS comment_karma

               }.squish).
        order(:username)
    end

    def pagination_params
      {
        page: params.fetch(:page, DEFAULT_PAGE),
        per_page: params.fetch(:per_page, DEFAULT_PER_PAGE),
        order: { username: :desc }
      }
    end

    def ban_user_params
      params.require(:ban_user_form).permit(:ban_duration, :ban_reason)
    end
  end
end
