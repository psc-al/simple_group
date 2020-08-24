class InboxItem < ApplicationRecord
  belongs_to :user
  belongs_to :inboxable, polymorphic: true

  scope :unread, -> { where(read: false) }
end
