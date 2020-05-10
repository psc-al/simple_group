RSpec.describe NavbarHelper do
  describe "#users_link_for" do
    context "when the user is present" do
      it "is a link to edit the user's profile" do
        user = create(:user)

        link_text, url = helper.users_link_for(user)

        expect(link_text).to eq(user.username)
        expect(url).to eq(edit_user_registration_path)
      end
    end

    context "when the user is nil" do
      it "is the signin link" do
        link_text, url = helper.users_link_for(nil)

        expect(link_text).to eq(t("devise.sessions.new.sign_in"))
        expect(url).to eq(new_user_session_path)
      end
    end
  end
end
