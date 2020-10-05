# frozen_string_literal: true

class ThreadReplyNotificationFilterForm
  include ActiveModel::Model

  MODEL_NAME = "ThreadReplyNotificationFilterForm"

  def initialize(params)
    @replies_to_comments = params[:replies_to_comments] == "1"
    @replies_to_submissions = params[:replies_to_submissions] == "1"
    @dismissed = params[:dismissed] == "1"
  end

  attr_reader :replies_to_comments, :replies_to_submissions, :dismissed
end
