require "support/page_objects/page_base"
require "support/page_objects/shared_components/user_form_components"

class UserEditPage < PageBase
  include UserFormComponents
  def visit(as:)
    login_as(as)
    super edit_user_registration_path(as.id)
    self
  end

  def fill_in_email(str)
    fill_in :user_email, with: str
    self
  end

  def fill_in_current_password(str)
    fill_in :user_current_password, with: str
    self
  end

  def fill_in_new_password(str)
    fill_in :user_password, with: str
    self
  end

  def fill_in_new_password_confirm(str)
    fill_in :user_password_confirmation, with: str
    self
  end

  def submit_form
    click_on t("users.registrations.edit.update")
    self
  end

  def fill_in_recipient_email(str)
    fill_in :user_invitation_recipient_email, with: str
    self
  end

  def send_invite
    click_on t("helpers.submit.user_invitation.create")
    self
  end

  def has_update_needs_confirmation_notice?
    has_notice?(t("users.registrations.update_needs_confirmation"))
  end

  def has_account_updated_successfully_notice?
    has_notice?(t("users.registrations.updated"))
  end

  def has_user_invited_notice?
    has_notice?(t("user_invitations.create.invited"))
  end

  def has_invite_error?
    has_alert?(t("user_invitations.create.invite_error"))
  end

  def has_sender_invite_error?
    has_alert?(t("user_invitations.errors.sender_error"))
  end

  def has_sent_invite_for?(invite)
    within find(".invite-table") do
      has_css?("#invite-#{invite.id}") && (within find("#invite-#{invite.id}") do
        has_css?("td", text: invite.recipient_email) &&
          has_css?("td", text: invite.sent_at) &&
          has_css?("td", text: invite.accepted_at)
      end)
    end
  end
end
