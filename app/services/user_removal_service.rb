class UserRemovalService
  def initialize(user)
    @user = user
  end

  def remove
    ApplicationRecord.transaction do
      remove_submission_data
      remove_comment_data
      remove_invitation_data
      deactivate_user
    end
  end

  private

  # rubocop:disable Rails/SkipsModelValidations

  def remove_submission_data
    user.submissions.where(url: nil).update_all(body: User::DELETED)
  end

  def remove_comment_data
    user.comments.update_all(body: User::DELETED)
  end

  def remove_invitation_data
    user.received_user_invitation&.update_column(:recipient_email, User::DELETED)
  end

  def deactivate_user
    password = SecureRandom.uuid

    user.update!(
      password: password,
      password_confirmation: password
    )

    user.update_columns(
      email: User::DELETED,
      confirmation_token: nil,
      confirmed_at: nil,
      confirmation_sent_at: nil,
      unconfirmed_email: User::DELETED,
      unlock_token: nil,
      locked_at: Time.zone.now,
      role: :deactivated,
      username: User::DELETED
    )
  end

  # rubocop:enable Rails/SkipsModelValidations

  attr_reader :user
end
