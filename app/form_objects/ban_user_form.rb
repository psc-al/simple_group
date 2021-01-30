# frozen_string_literal: true

class BanUserForm
  include ActiveModel::Model

  MODEL_NAME = "BanUserForm"
  BAN_DURATIONS = %w[1_day 1_week 1_month 3_months permanent].freeze

  def initialize(params)
    @now = DateTime.current
    @ban_duration = params[:ban_duration]
    @ban_reason = params[:ban_reason]
  end

  def to_attributes_hash
    {
      banned_at: now,
      ban_type: calculate_ban_type,
      temp_ban_end_at: calculate_temp_ban_end_at,
      ban_reason: ban_reason
    }
  end

  def calculate_ban_type
    if ban_duration == "permanent"
      :perma
    else
      :temp
    end
  end

  def calculate_temp_ban_end_at
    if ban_duration == "permanent"
      DateTime::Infinity
    else
      length, unit = ban_duration.split("_")
      now + length.to_i.send(unit)
    end
  end

  attr_reader :now, :ban_duration, :ban_reason

  private

  attr_reader :params
end
