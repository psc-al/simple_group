RSpec.describe "user fills out registration form" do
  let(:page) { UserRegistrationPage.new }

  context "when the user has a valid invite token" do
    context "when the form is valid" do
      it "registers the user and gives a confirmation message" do
        page.visit.fill_out_form({
          username: "foobar",
          email: "foobar@baz.com",
          password: "abcd1234",
          password_confirmation: "abcd1234"
        })

        # there is a user that sent the invite initially
        expect { page.submit_form }.to change { User.count }.from(1).to(2)
        expect(page).to have_signed_up_but_unconfirmed_notice

        user = User.find_by(email: "foobar@baz.com")

        expect(user.username).to eq("foobar")
        expect(user.email).to eq("foobar@baz.com")
        expect(user.valid_password?("abcd1234")).to eq(true)
        expect(user).not_to be_confirmed
      end
    end

    context "when the form is not valid" do
      context "when the username is missing" do
        it "tells the user that the username is required" do
          page.visit.fill_out_form({
            email: "foobar@baz.com",
            password: "abcd1234",
            password_confirmation: "abcd1234"
          }).submit_form

          expect(page).to have_missing_username_error
        end
      end

      context "when the email is missing" do
        it "tells the user that the email is required" do
          page.visit.fill_out_form({
            email: "",
            username: "foobar",
            password: "abcd1234",
            password_confirmation: "abcd1234"
          }).submit_form

          expect(page).to have_missing_email_error
        end
      end

      context "when password is missing" do
        it "tells the user that the passwords must match" do
          page.visit.fill_out_form({
            email: "foobar@baz.com",
            username: "foobar",
            password_confirmation: "abcd12345"
          }).submit_form

          expect(page).to have_missing_password_error
        end
      end
    end
  end

  context "when the invite token is invalid" do
    it "redirects the user to the root url" do
      page.visit(invite_token: "foo")

      expect(page).to have_current_path(root_path)
    end
  end

  context "when the user does not have an invite token" do
    it "redirects the user to the root url" do
      page.visit(invite_token: nil)

      expect(page).to have_current_path(root_path)
    end
  end
end
