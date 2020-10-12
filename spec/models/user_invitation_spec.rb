RSpec.describe UserInvitation, type: :model do
  describe "#send_invitation" do
    let(:invitation) { create(:user_invitation) }

    it "sends an email" do
      expect { invitation.send_invitation }.
        to change { ActionMailer::Base.deliveries.count }.from(0).to(1)
    end
  end
end
