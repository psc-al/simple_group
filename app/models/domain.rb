# frozen_string_literal: true

class Domain < ApplicationRecord
  belongs_to :banned_by, class_name: "User", optional: true
  has_many :submissions

  def banned?
    banned_at.present?
  end
end
