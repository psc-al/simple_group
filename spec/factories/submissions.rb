FactoryBot.define do
  factory :submission do
    user
    sequence(:title) { |n| "A Very Useful Title #{n}" }
    original_author { false }
  end

  trait :url do
    sequence(:url) { |n| "https://www.somesite#{n}.com/path/to/content" }
    domain { build(:domain, name: URI.parse(url).host) }
    body { nil }
  end

  trait :text do
    url { nil }
    domain { nil }
    body { "A very useful text body" }
  end

  trait :with_all_tags do
    after(:build) do |submission|
      Tag.kinds.each_key do |kind|
        submission.tags << build(:"#{kind}_tag")
      end
    end
  end

  trait :with_comments do
    transient do
      num_comments { 3 }
    end
    after(:build) do |submission, evaluator|
      submission.comments = build_list(:comment, evaluator.num_comments)
    end
  end

  trait :removed do
    removed { true }
    transient do
      removed_by { build(:user, :admin) }
      reason { :spam }
    end

    after(:build) do |submission, evaluator|
      submission.submission_removal = build(
        :submission_removal,
        reason: evaluator.reason,
        removed_by: evaluator.removed_by,
        submission: submission
      )
    end
  end
end
