RSpec.describe "User sessions" do
  describe "POST /users/sign_in" do
    context "when the username is `[deleted]`" do
      it "doesn't even attempt a login and redirects to the sign in path" do
        user = create(:user, password: "abcd1234")
        # rubocop:disable Rails/SkipsModelValidations
        user.update_column(:username, "[deleted]")
        # rubocop:enable Rails/SkipsModelValidations

        post "/users/sign_in", params: {
          user: {
            username: "[deleted]",
            password: "abcd1234"
          }
        }

        expect(response).to redirect_to new_user_session_path
      end
    end

    context "when the user is deactivated" do
      it "renders the sign in page and says the login credentials are invalid" do
        user = create(:user, :deactivated, password: "abcd1234")

        post "/users/sign_in", params: {
          user: {
            username: user.username,
            password: "abcd1234"
          }
        }

        expect(response.body).to match("Invalid Username or password")
      end
    end
  end
end
