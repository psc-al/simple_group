RSpec.describe "user edits account" do
  let(:page) { UserEditPage.new }
  let(:user) { create(:user, password: "abcd1234") }

  context "editing email" do
    it "notifies the user that their new email has to be confirmed" do
      page.
        visit(as: user).
        fill_in_email("newemail@beep.com").
        fill_in_current_password("abcd1234").
        submit_form

      expect(page).to have_update_needs_confirmation_notice

      user.reload

      expect(user.unconfirmed_email).to eq("newemail@beep.com")
      expect(user).to be_pending_reconfirmation
    end
  end

  context "current password is incorrect", js: true do
    it "allows no updates" do
      email = user.email

      page.
        visit(as: user).
        fill_in_email("newemail@beep.com").
        toggle_edit_password.
        fill_in_current_password("abcd12345").
        fill_in_new_password("4321dcba").
        fill_in_new_password_confirm("4321dcba").
        submit_form

      expect(page).to have_invalid_field_error(".user_current_password")

      user.reload

      expect(user.email).to eq(email)
      expect(user.unconfirmed_email).to be_nil
      expect(user.valid_password?("4321dcba")).to eq(false)
    end
  end

  context "password update", js: true do
    it "updates the user's password and redirects them to the root path" do
      page.
        visit(as: user).
        toggle_edit_password.
        fill_in_current_password("abcd1234").
        fill_in_new_password("4321dcba").
        fill_in_new_password_confirm("4321dcba").
        submit_form

      expect(page).to have_account_updated_successfully_notice
      expect(page).to have_current_path(root_path)

      user.reload

      expect(user.valid_password?("4321dcba")).to eq(true)
    end

    it "requires the passwords to match" do
      page.
        visit(as: user).
        toggle_edit_password.
        fill_in_current_password("abcd1234").
        fill_in_new_password("4321dcba").
        fill_in_new_password_confirm("4321xdcba").
        submit_form

      expect(page).to have_mismatched_password_error

      user.reload

      expect(user.valid_password?("4321dcba")).to eq(false)
    end
  end
end
