require "support/page_objects/page_base"
require "support/page_objects/shared_components/form_errors"
require "support/page_objects/shared_components/user_form_components"

class UserRegistrationPage < PageBase
  include UserFormComponents

  def visit(invite_token: create(:user_invitation).token)
    super new_user_registration_path(invite_token: invite_token)
    self
  end

  def fill_out_form(form_attributes)
    # unfortunately Capybara gets confused about the password + confirmation
    # for some reason because of how formulaic tries to fill out the form
    # so we need to do them separately
    password = form_attributes.delete(:password)
    password_confirmation = form_attributes.delete(:password_confirmation)
    fill_form(:user, form_attributes)

    fill_in :user_password, with: password
    fill_in :user_password_confirmation, with: password_confirmation
    self
  end

  def submit_form
    click_on t("users.registrations.new.sign_up")
    self
  end

  def has_signed_up_but_unconfirmed_notice?
    has_notice?(t("users.registrations.signed_up_but_unconfirmed"))
  end

  def has_missing_username_error?
    has_missing_field_error?(".user_username")
  end
end
