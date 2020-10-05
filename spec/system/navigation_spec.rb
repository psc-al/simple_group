RSpec.describe "navigation" do
  let(:page) { SubmissionsIndexPage.new }

  context "user is not logged in" do
    it "can see and click on the sign in link on the navbar" do
      page.visit

      expect(page).to have_login_link

      page.visit_sign_in_link

      expect(page).to have_current_path(new_user_session_path)
    end

    it "cannot see links that require a signed in user" do
      page.visit

      expect(page).not_to have_submit_link
      expect(page).not_to have_inbox_link
      expect(page).
        not_to have_link(I18n.t("footer.submissions.user"))
    end
  end

  context "user is logged in" do
    it "can see and click on their username to edit their profile" do
      user = create(:user)

      page.visit(as: user)

      expect(page).to have_edit_profile_link_for(user)

      page.visit_profile_link_for(user)

      expect(page).to have_current_path(edit_user_registration_path)
    end

    it "can see and click a link to make a submission" do
      user = create(:user)

      page.visit(as: user)

      expect(page).to have_submit_link

      page.visit_submit_link

      expect(page).to have_current_path(new_submission_path)
    end

    context "when the user has inbox notifications" do
      it "can see and click a decorated link to go to their inbox" do
        user = create(:user)
        create(:thread_reply_notification, recipient: user)

        page.visit(as: user)

        expect(page).to have_inbox_link(classes: "notify")

        page.visit_inbox_link

        expect(page).to have_current_path(inbox_path)
      end
    end

    context "when the user has no inbox notifications" do
      it "can see and click an undecorated link to go to their inbox" do
        user = create(:user)

        page.visit(as: user)

        expect(page).to have_inbox_link

        page.visit_inbox_link

        expect(page).to have_current_path(inbox_path)
      end
    end

    it "can see and click a link to view their submissions" do
      user = create(:user)

      page.visit(as: user)

      expect(page).to have_submissions_link_for(user)

      page.visit_user_submissions_link

      expect(page).to have_current_path(user_submissions_path(user.username))
    end
  end
end
