FactoryBot.define do
  factory :submission do
    sequence(:title) { |n| "A Very Useful Title #{n}" }
    sequence(:url) { |n| "https://www.somesite#{n}.com/path/to/content" }
    body { nil }
    user
    original_author { false }
    domain
  end
end
