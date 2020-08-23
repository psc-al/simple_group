# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  def create
    if sign_in_params[:username].downcase == User::DELETED
      redirect_to new_user_session_path
    else
      super
    end
  end
end
