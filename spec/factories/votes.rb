FactoryBot.define do
  factory :vote do
    user

    trait :submission do
      association :votable, factory: [:submission, :text]
    end

    trait :comment do
      association :votable, factory: :comment
    end

    factory :upvote do
      kind { :upvote }
    end

    factory :downvote do
      kind { :downvote }
    end
  end
end
