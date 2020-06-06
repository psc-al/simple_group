class UserInvitationsController < ApplicationController
  before_action :authenticate_user!

  def create
    invite_params = user_invitation_params
    if UserInvitation.where(recipient_email: invite_params[:recipient_email]).exists?
      redirect_to edit_user_registration_path, alert: t(".already_invited")
    else
      create_invitation_and_send(invite_params)
    end
  end

  private

  def create_invitation_and_send(_invite_params)
    invite = UserInvitation.new(user_invitation_params)
    if invite.valid?
      invite.save!
      send_invite_and_redirect(invite)
    else
      redirect_to edit_user_registration_path, alert: invite.errors.values.join(",")
    end
  end

  def send_invite_and_redirect(invite)
    flash = if invite.send_invitation
              { notice: t(".invited") }
            else
              { alert: t(".invite_error") }
            end
    redirect_to edit_user_registration_path, flash
  end

  def user_invitation_params
    params.require(:user_invitation).permit(:recipient_email).merge(
      sender_id: current_user.id,
      token: Devise.friendly_token(32)
    )
  end
end
