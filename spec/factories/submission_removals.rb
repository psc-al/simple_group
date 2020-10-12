FactoryBot.define do
  factory :submission_removal do
    association :removed_by, factory: [:user, :admin]
    association :submission, factory: [:submission, :removed]
    reason { 1 }
    details { "MyText" }
  end
end
