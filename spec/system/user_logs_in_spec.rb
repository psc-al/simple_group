RSpec.describe "User logs in" do
  let(:page) { UserLoginPage.new }

  before { page.visit }

  context "when the user is not banned" do
    it "signs the user in and redirects them to the submissions index" do
      user = create(:user, password: "abcd1234")

      page.fill_in_username(user.username).fill_in_password("abcd1234").submit_form

      expect(page).to have_notice("Signed in successfully")
    end
  end

  context "when the user is perma banned" do
    it "flashes a permaban message, logs them back out, and redirects them to the submission index" do
      user = create(:user, password: "abcd1234", ban_type: :perma, banned_at: Time.current)

      page.fill_in_username(user.username).fill_in_password("abcd1234").submit_form

      expect(page).to have_alert(I18n.t("users.banned.permaban_flash"))
    end
  end

  context "when the user is temp banned" do
    it "flashes a tempban message, logs them back out, and redirects them to the submission index" do
      travel_to DateTime.new(2020) do
        user = create(
          :user,
          password: "abcd1234",
          ban_type: :temp,
          banned_at: Time.current,
          temp_ban_end_at: 5.days.from_now
        )

        page.fill_in_username(user.username).fill_in_password("abcd1234").submit_form

        expect(page).to have_alert(I18n.t("users.banned.tempban_flash", return_at: 5.days.from_now))
      end
    end
  end
end
