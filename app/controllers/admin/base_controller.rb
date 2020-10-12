module Admin
  class BaseController < ApplicationController
    before_action :authenticate_admin!

    private

    def authenticate_admin!
      authenticate_user!
      head :forbidden unless current_user.admin? || current_user.moderator?
    end
  end
end
