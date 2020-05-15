FactoryBot.define do
  factory :tag do
    factory :topic_tag do
      sequence(:id) { |n| "topic-tag-#{n}" }
      sequence(:description) { |n| "topic tag description #{n}" }
      kind { :topic }
    end

    factory :media_tag do
      sequence(:id) { |n| "media-tag-#{n}" }
      sequence(:description) { |n| "media tag description #{n}" }
      kind { :media }
    end

    factory :source_tag do
      sequence(:id) { |n| "source-tag-#{n}" }
      sequence(:description) { |n| "source tag description #{n}" }
      kind { :source }
    end

    factory :meta_tag do
      sequence(:id) { |n| "meta-tag-#{n}" }
      sequence(:description) { |n| "meta tag description #{n}" }
      kind { :meta }
    end

    factory :mod_tag do
      sequence(:id) { |n| "mod-tag-#{n}" }
      sequence(:description) { |n| "mod tag description #{n}" }
      kind { :mod }
    end
  end
end
