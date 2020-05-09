module NavigationComponent
  def has_login_link?
    within(".navbar-links") do
      has_link?(t("users.sessions.new.sign_in"), href: new_user_session_path)
    end
  end

  def visit_sign_in_link
    within(".navbar-links") do
      click_link(t("users.sessions.new.sign_in"))
    end
  end

  def has_edit_profile_link_for?(user)
    within(".navbar-links") do
      has_link?(user.username, href: edit_user_registration_path)
    end
  end

  def visit_profile_link_for(user)
    within(".navbar-links") do
      click_link(user.username)
    end
  end
end
