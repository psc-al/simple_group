# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  before_action :configure_sign_up_params, only: [:create]
  before_action :configure_account_update_params, only: [:update]

  def edit
    @invitations = current_user.sent_user_invitations
    super
  end

  def update
    @invitations = current_user.sent_user_invitations
    super
  end

  def new
    token = params[:invite_token]
    @invite = UserInvitation.find_by(token: token) if token.present?
    if @invite.present?
      super
    else
      redirect_to root_path
    end
  end

  def create
    token = params.fetch(:user, {}).fetch(:invite_token, nil)
    @invite = UserInvitation.find_by(token: token) if token.present?
    if @invite.present?
      super
    else
      head :forbidden
    end
  end

  def destroy
    UserRemovalService.new(current_user).remove
    Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name)
    set_flash_message! :notice, :destroyed
    redirect_to root_path
  end

  protected

  def configure_sign_up_params
    devise_parameter_sanitizer.permit(
      :sign_up,
      keys: [:username, :email, :password]
    )
  end

  def configure_account_update_params
    devise_parameter_sanitizer.permit(
      :account_update,
      keys: [:email, :password]
    )
  end
end
