class ApplicationController < ActionController::Base
  before_action :sign_out_banned_users

  private

  def sign_out_banned_users
    if current_user.present? && current_user.banned?
      flash = ban_flash
      sign_out
      redirect_to root_path, alert: flash
    end
  end

  def ban_flash
    if current_user.perma_banned?
      t("users.banned.permaban_flash")
    else
      t("users.banned.tempban_flash", return_at: current_user.temp_ban_end_at)
    end
  end
end
