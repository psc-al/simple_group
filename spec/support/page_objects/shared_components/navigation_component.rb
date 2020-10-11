module NavigationComponent
  def has_submit_link?
    within(".navbar-links") do
      has_link?(t("navigation.links.submit"), href: new_submission_path)
    end
  end

  def visit_submit_link
    within(".navbar-links") do
      click_link(t("navigation.links.submit"))
    end
  end

  def has_submissions_link_for?(user)
    within(".footer") do
      has_link?(t("footer.submissions.user"), href: user_submissions_path(user.username))
    end
  end

  def visit_user_submissions_link
    within(".footer") do
      click_link(t("footer.submissions.user"))
    end
  end

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
