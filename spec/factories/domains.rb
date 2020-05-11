FactoryBot.define do
  factory :domain do
    sequence(:name) { |n| "domain#{n}.com" }
    tracker { false }
    banned_at { nil }
    banned_by { nil }

    trait :banned do
      transient do
        banned_at { Time.zone.now }
        banned_by { build(:user) }
      end

      after(:build) do |domain, evaluator|
        domain.banned_at = evaluator.banned_at
        domain.banned_by = evaluator.banned_by
      end
    end
  end
end
