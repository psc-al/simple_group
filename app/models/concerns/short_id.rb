# frozen_string_literal: true

module ShortId
  extend ActiveSupport::Concern

  included do
    extend ::FriendlyId
    before_create :set_short_id
    friendly_id :short_id
  end

  def set_short_id
    short_id = nil

    loop do
      short_id = "#{self.class.short_id_prefix}#{SecureRandom.base36(8)}"
      break unless self.class.name.constantize.where(short_id: short_id).exists?
    end

    self.short_id = short_id
  end
end
