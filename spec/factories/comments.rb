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
  end
end
