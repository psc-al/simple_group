RSpec.describe "user registrations" do
  describe "GET /users/sign_up" do
    context "when invite token is present and valid" do
      it "responds with 200" do
        invite = create(:user_invitation)

        get "/users/sign_up?invite_token=#{invite.token}"

        expect(response).to be_ok
      end
    end

    context "when invite token is not valid" do
      it "responds with a redirect" do
        get "/users/sign_up?invite_token=abcd1234"

        expect(response).to be_redirect
      end
    end

    context "when invite token is not present" do
      it "responds with a redirect" do
        get "/users/sign_up"

        expect(response).to be_redirect
      end
    end
  end

  describe "POST /users" do
    context "when the invite token is present and valid" do
      it "creates the user and responds with 302 redirect" do
        invite = create(:user_invitation)
        params = {
          invite_token: invite.token,
          email: "abcd@foo.com",
          username: "beebop",
          password: "abcd1234",
          password_confirmation: "abcd1234"
        }

        post "/users", params: { user: params }

        expect(response).to be_redirect

        user = User.find_by(username: "beebop")

        expect(user).to be_a(User)
        expect(user.email).to eq("abcd@foo.com")
      end
    end

    context "when the invite token is not present" do
      it "responds with 403 forbidden" do
        params = {
          email: "abcd@foo.com",
          username: "beebop",
          password: "abcd1234",
          password_confirmation: "abcd1234"
        }

        post "/users", params: { user: params }

        expect(response).to be_forbidden
      end
    end
  end
end
