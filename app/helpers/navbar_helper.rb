module NavbarHelper
  def users_link_for(current_user)
    if current_user.present?
      [current_user.username, edit_user_registration_path]
    else
      [t("devise.sessions.new.sign_in"), new_user_session_path]
    end
  end
end
