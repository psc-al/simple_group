class UserCommentsController < ApplicationController
  DEFAULT_PAGE = 0
  DEFAULT_PER_PAGE = 25

  def index
    @user = User.find_by!(username: params[:username])
    @paginator = ResultsPaginator.new(
      @user.comments.includes(:submission, parent: :user),
      pagination_params
    )
  end

  private

  def pagination_params
    {
      page: params.fetch(:page, DEFAULT_PAGE),
      per_page: params.fetch(:per_page, DEFAULT_PER_PAGE),
      order: { created_at: :desc }
    }
  end
end
