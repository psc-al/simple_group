require "support/page_objects/page_base"

class UserLoginPage < PageBase
  def visit
    super new_user_session_path
    self
  end

  def fill_in_username(username)
    fill_in :user_username, with: username
    self
  end

  def fill_in_password(password)
    fill_in :user_password, with: password
    self
  end

  def submit_form
    within find ".form-actions" do
      click_on "Log in"
    end
    self
  end
end
