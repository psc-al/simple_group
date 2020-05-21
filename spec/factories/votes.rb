FactoryBot.define do
  factory :vote do
    user

    factory :upvote do
      kind { :upvote }

      trait :submission do
        association :votable, factory: [:submission, :text]
      end

      trait :comment do
        association :votable, factory: :comment
      end
    end

    factory :downvote do
      kind { :downvote }

      trait :submission do
        association :votable, factory: [:submission, :text]
        downvote_reason { Vote::SUBMISSION_DOWNVOTE_REASONS.sample }
      end

      trait :comment do
        association :votable, factory: :comment
        downvote_reason { Vote::COMMENT_DOWNVOTE_REASONS.sample }
      end
    end
  end
end
