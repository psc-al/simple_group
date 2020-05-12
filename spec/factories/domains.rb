FactoryBot.define do
  factory :domain do
    sequence(:name) { |n| "domain#{n}.com" }
    tracker { false }
    banned_at { nil }
    banned_by { nil }
  end
end
