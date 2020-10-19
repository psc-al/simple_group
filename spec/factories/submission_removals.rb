FactoryBot.define do
  factory :submission_removal do
    association :removed_by, factory: [:user, :admin]
    submission { association :submission, removed: true }
    reason { :spam }
    details { "MyText" }
  end
end
