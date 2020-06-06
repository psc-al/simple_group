RSpec.describe "user invites user" do
  let(:page) { UserEditPage.new }

  it "displays a list of the users sent invitations" do
    user = create(:user)
    invites = create_list(:user_invitation, 3, sender: user)

    page.visit(as: user)

    invites.each do |invite|
      expect(page).to have_sent_invite_for(invite)
    end
  end

  context "when a user is an admin" do
    it "can invite a user" do
      admin = create(:user, :admin)
      page.visit(as: admin).fill_in_recipient_email("foo@bar.com")

      expect { page.send_invite }.to change(UserInvitation, :count).from(0).to(1)
      expect(page).to have_user_invited_notice
      expect(admin.sent_user_invitations.count).to eq(1)
      expect(page).to have_sent_invite_for(admin.sent_user_invitations.reload.first)
    end
  end

  context "when a user is not an admin" do
    context "when the user has not sent the maximum amount of invites today" do
      it "can invite a user" do
        user = create(:user)
        page.visit(as: user).fill_in_recipient_email("foo@bar.com")

        expect { page.send_invite }.to change(UserInvitation, :count).from(0).to(1)
        expect(page).to have_user_invited_notice
        expect(user.sent_user_invitations.count).to eq(1)
        expect(page).to have_sent_invite_for(user.sent_user_invitations.reload.first)
      end
    end

    context "when the user has sent the maximum amount of invites today" do
      it "cannot invite a user" do
        user = create(:user)
        now = Time.zone.now
        travel_to now do
          create_list(:user_invitation, 10, sender: user)
          page.visit(as: user).fill_in_recipient_email("foo@bar.com")

          expect { page.send_invite }.not_to change(UserInvitation, :count)
          expect(page).to have_sender_invite_error
        end
      end
    end
  end
end
