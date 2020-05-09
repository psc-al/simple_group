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

  validates :username, presence: true

  def self.find_first_by_auth_conditions(warden_conditions)
    warden_conditions.fetch(:username, nil).then do |username|
      where("lower(username) = ?", username.downcase).first if username.present?
    end
  end
end
