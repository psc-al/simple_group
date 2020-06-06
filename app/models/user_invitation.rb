class UserInvitation < ApplicationRecord
  belongs_to :sender, class_name: :User
  belongs_to :recipient, class_name: :User, optional: true

  validates :recipient_email, email: true
  validate :sender_can_invite

  def send_invitation
    UserInvitationMailer.with(invite: self).invite_email.deliver_now
    update!(sent_at: Time.zone.now)
  end

  private

  def sender_can_invite
    unless sender.can_invite?
      errors.add(:sender, I18n.t("user_invitations.errors.sender_error"))
    end
  end
end
