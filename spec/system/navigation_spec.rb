RSpec.describe "navigation" do
  let(:page) { SubmissionsIndexPage.new }

  context "user is not logged in" do
    it "can see and click on the sign in link on the navbar" do
      page.visit

      expect(page).to have_login_link

      page.visit_sign_in_link

      expect(page).to have_current_path(new_user_session_path)
    end
  end

  context "user is logged in" do
    it "can see and click on their username to edit their profile" do
      user = create(:user)

      page.visit(as: user)

      expect(page).to have_edit_profile_link_for(user)

      page.visit_profile_link_for(user)

      expect(page).to have_current_path(edit_user_registration_path)
    end
  end
end
