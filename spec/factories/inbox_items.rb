FactoryBot.define do
  factory :inbox_item do
    user { nil }
    inboxable { nil }
    read { false }
  end
end
