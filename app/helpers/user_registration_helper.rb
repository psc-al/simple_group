module UserRegistrationHelper
  def change_password_fields_class(resource)
    unless has_password_errors?(resource)
      "hidden"
    end
  end

  def password_change_field_disabled?(resource)
    !has_password_errors?(resource)
  end

  private

  def has_password_errors?(resource)
    resource.errors.include?(:password) || resource.errors.include?(:password_confirmation)
  end
end
