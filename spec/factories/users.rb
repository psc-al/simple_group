FactoryBot.define do
  factory :user do
    sequence(:username) { |n| "testuser#{n}" }
    sequence(:email) { |n| "testuser#{n}@example.com" }
    password { "abcd1234" }
    password_confirmation { password }
    confirmed_at { Time.now }
    role { :member }

    trait(:admin) { role { :admin } }
    trait(:moderator) { role { :moderator } }
    trait(:deactivated) { role { :deactivated } }
  end
end
