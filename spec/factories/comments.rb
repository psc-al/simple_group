FactoryBot.define do
  factory :comment do
    user
    parent { nil }
    submission do
      if parent.present?
        parent.submission
      else
        build(:submission)
      end
    end
    sequence(:body) { |n| "a great comment body text #{n}" }

    trait :removed do
      removed { true }
      transient do
        removed_by { build(:user, :admin) }
        reason { :spam }
      end

      after(:build) do |comment, evaluator|
        comment.comment_removal = build(
          :comment_removal,
          reason: evaluator.reason,
          removed_by: evaluator.removed_by,
          comment: comment
        )
      end
    end
  end
end
