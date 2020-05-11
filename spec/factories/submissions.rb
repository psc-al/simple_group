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
end
