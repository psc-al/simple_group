class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable, :lockable, authentication_keys: [:username]

  enum role: {
    member: 0,
    moderator: 10,
    admin: 20
  }

  has_many :submissions

  validates :username, presence: true

  def self.find_first_by_auth_conditions(warden_conditions)
    warden_conditions.fetch(:username, nil).then do |username|
      where("lower(username) = ?", username.downcase).first if username.present?
    end
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
end
