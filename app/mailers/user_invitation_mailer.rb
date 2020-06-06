class UserInvitationMailer < ApplicationMailer
  def invite_email
    @invite = params[:invite]
    @sender = @invite.sender.username
    @url = "#{new_user_registration_url}?invite_token=#{@invite.token}"
    mail(to: @invite.recipient_email, subject: t(".subject", sender: @sender))
  end
end
