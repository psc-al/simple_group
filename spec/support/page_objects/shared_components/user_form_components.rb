require "support/page_objects/shared_components/form_errors"
module UserFormComponents
  include FormErrors

  def has_missing_email_error?
    has_missing_field_error?(".user_email")
  end

  def has_missing_password_error?
    has_missing_field_error?(".user_password")
  end

  def has_mismatched_password_error?
    has_css?(
      ".user_password_confirmation.field_with_errors",
      text: t('errors.messages.confirmation', attribute: 'Password')
    )
  end
end
