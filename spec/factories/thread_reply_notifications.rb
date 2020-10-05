FactoryBot.define do
  factory :thread_reply_notification do
    association :recipient, factory: :user
    in_response_to_comment { nil }
    reply { nil }
    dismissed { false }

    after(:build) do |n|
      submission = build(:submission, :url, user: n.recipient)
      comment = build(:comment, submission: submission)
      if n.in_response_to_comment.present?
        comment.parent = n.in_response_to_comment
      end
      n.reply = comment
      submission.comments << n.reply
    end
  end
end
