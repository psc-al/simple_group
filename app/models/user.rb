# frozen_string_literal: true

class User < ApplicationRecord
  DELETED = "[deleted]"

  INVITES_PER_DAY = 10
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable, :lockable, authentication_keys: [:username]

  enum role: {
    member: 0,
    moderator: 10,
    admin: 20,
    deactivated: 100
  }

  enum ban_type: {
    temp: 0,
    perma: 1
  }, _suffix: :banned

  has_many :submissions
  has_many :submission_actions
  has_many :comments
  has_many :votes
  has_many :sent_user_invitations, foreign_key: :sender_id, class_name: :UserInvitation
  has_many :thread_reply_notifications, foreign_key: :recipient_id
  has_many :flattened_thread_reply_notifications, foreign_key: :recipient_id
  has_one :received_user_invitation, foreign_key: :recipient_id, class_name: :UserInvitation, required: false
  belongs_to :banned_by, class_name: "User", optional: true

  validates :username, presence: true
  validate :username_not_restricted?

  scope :active, -> { where.not(role: :deactivated) }

  def self.find_first_by_auth_conditions(warden_conditions)
    if warden_conditions.key?(:confirmation_token)
      super
    else
      warden_conditions.fetch(:username, nil).then do |username|
        active.where("lower(username) = ?", username.downcase).first if username.present?
      end
    end
  end

  def self.include_submission_counts_and_karma
    joins(
      %{
        LEFT JOIN (
          SELECT submissions.user_id, COUNT(1) AS submission_count,
          SUM(
            (
              (
                SELECT COUNT(votable_id) FROM votes
                WHERE votable_type = 'Submission' AND votable_id = submissions.id AND kind = 0
              ) -
              (
                SELECT COUNT(votable_id) FROM votes
                WHERE votable_type = 'Submission' AND votable_id = submissions.id AND kind = 1
              )
            )
          )::integer AS submission_karma
          FROM submissions
          GROUP BY submissions.user_id
        ) scs
        ON users.id = scs.user_id
      }.squish
    )
  end

  def self.include_comment_counts_and_karma
    joins(
      %{
        LEFT JOIN (
          SELECT comments.user_id, COUNT(1) AS comment_count,
          SUM(
            (
              (
                SELECT COUNT(votable_id) FROM votes
                WHERE votable_type = 'Comment' AND votable_id = comments.id AND kind = 0
              ) -
              (
                SELECT COUNT(votable_id) FROM votes
                WHERE votable_type = 'Comment' AND votable_id = comments.id AND kind = 1
              )
            )
          )::integer AS comment_karma
          FROM comments
          GROUP BY comments.user_id
        ) ccs
        ON users.id = ccs.user_id
      }.squish
    )
  end

  def banned?
    (banned_at.present? && unbanned_at.nil?) ||
      (
        banned_at.present? && unbanned_at.nil? &&
        temp_ban_end_at.present? && Time.current < temp_ban_end_at
      )
  end

  def update_last_submission_at!
    update!(last_submission_at: Time.zone.now)
  end

  def minutes_until_next_submission
    if last_submission_at.nil?
      0.0
    else
      last_submitted = last_submission_at.in_time_zone(Time.zone)
      [(10.minutes.since(last_submitted) - Time.zone.now) / 1.minute, 0.0].max.round
    end
  end

  def can_invite?
    admin? || daily_invites_under_maximum?
  end

  def has_mod_permissions?
    admin? || moderator?
  end

  private

  def daily_invites_under_maximum?
    now = Time.zone.now
    sent_user_invitations.
      where(sent_at: (now.beginning_of_day..now.end_of_day)).
      count < INVITES_PER_DAY
  end

  def username_not_restricted?
    if username.present? && username.downcase == DELETED
      errors.add(:username, :invalid)
    end
  end
end
