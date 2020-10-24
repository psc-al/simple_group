FactoryBot.define do
  factory :comment_removal do
    comment
    association :removed_by, factory: [:user, :admin]
    reason { 0 }
    details { "MyText" }
  end
end
