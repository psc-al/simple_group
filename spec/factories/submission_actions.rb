FactoryBot.define do
  factory :submission_action do
    submission
    user

    trait :hidden do
      kind { :hidden }
    end

    trait :saved do
      kind { :saved }
    end
  end
end
