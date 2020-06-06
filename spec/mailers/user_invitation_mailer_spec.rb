RSpec.describe UserInvitationMailer do
  let(:invite) { create(:user_invitation) }
  let(:mailer) { UserInvitationMailer.with(invite: invite).invite_email }

  describe "#invite_email" do
    it "renders the subject" do
      expect(mailer.subject).
        to eq(I18n.t("user_invitation_mailer.invite_email.subject", sender: invite.sender.username))
    end

    it "renders the receiver email" do
      expect(mailer.to).to eq([invite.recipient_email])
    end

    it "renders the sender email" do
      sender_email = ENV.fetch("SMTP_SENDER_EMAIL", "foo@bar.com")

      expect(mailer.from).to eq([sender_email])
    end

    it "includes the body lines and an invite URL" do
      url = "#{new_user_registration_url}?invite_token=#{invite.token}"
      body = mailer.body.encoded
      expect(body).to include I18n.t("user_invitation_mailer.invite_email.line1", sender: invite.sender.username)
      expect(body).to include I18n.t("user_invitation_mailer.invite_email.line2")
      expect(body).to include I18n.t("user_invitation_mailer.invite_email.url", url: url)
    end
  end
end
