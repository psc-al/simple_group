# frozen_string_literal: true

class SubmissionSearch
  DEFAULT_PAGE = 0
  DEFAULT_PER_PAGE = 25

  def initialize(params, user)
    @params = params
    @user = user
  end

  def results_paginator
    ResultsPaginator.new(scope, pagination_params)
  end

  private

  attr_reader :params, :user

  def scope
    Submission.preload(:user, :domain, :tags).then do |rel|
      if user.present?
        # hidden submissions aren't going to show up on the index so we don't have
        # to select the action id here
        rel.left_join_saved_info_for(user).where(hidden_submissions.arel.exists.not).
          select("submissions.*, NULL AS hidden_action_id, saved_actions.id AS saved_action_id")
      else
        rel.select("submissions.*, NULL AS hidden_action_id, NULL AS saved_action_id")
      end
    end
  end

  def hidden_submissions
    user.
      submission_actions.hidden.
      where("submission_actions.submission_short_id = submissions.short_id").
      select(1)
  end

  def pagination_params
    {
      page: params.fetch(:page, DEFAULT_PAGE),
      per_page: params.fetch(:per_page, DEFAULT_PER_PAGE),
      order: { id: :desc }
    }
  end
end
