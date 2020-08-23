FactoryBot.define do
  factory :user_invitation do
    association :sender, factory: :user
    sequence(:recipient_email) { |n| "newuser#{n}@example.com" }
    sent_at { Time.zone.now }
    accepted_at { nil }
    token { SecureRandom.uuid }

    trait :accepted do
      association :recipient, factory: :user
      recipient_email { recipient.email }
    end
  end
end
