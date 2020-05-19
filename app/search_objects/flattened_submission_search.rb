# frozen_string_literal: true

class FlattenedSubmissionSearch
  DEFAULT_PAGE = 0
  DEFAULT_PER_PAGE = 25

  def initialize(params, user)
    @params = params
    @user = user
  end

  def by_short_id(short_id)
    scope(include_hidden: true).friendly.preload(:flattened_comments).find(short_id)
  end

  def results_paginator
    ResultsPaginator.new(scope, pagination_params)
  end

  private

  attr_reader :params, :user

  def scope(include_hidden: false)
    FlattenedSubmission.preload(:tags).then do |rel|
      if user.present?
        with_action_info(rel, include_hidden)
      else
        rel.select("flattened_submissions.*, NULL AS hidden_action_id, NULL AS saved_action_id")
      end
    end
  end

  def with_action_info(rel, include_hidden)
    if include_hidden
      rel.left_join_saved_info_for(user).left_join_hidden_info_for(user).select(%(
        flattened_submissions.*,
        hidden_actions.id AS hidden_action_id,
        saved_actions.id AS saved_action_id
      ).squish)
    else
      rel.left_join_saved_info_for(user).where(hidden_submissions.arel.exists.not).select(%(
        flattened_submissions.*,
        NULL AS hidden_action_id,
        saved_actions.id AS saved_action_id
      ).squish)
    end
  end

  def hidden_submissions
    user.
      submission_actions.hidden.
      where("submission_actions.submission_short_id = flattened_submissions.short_id").
      select(1)
  end

  def pagination_params
    {
      page: params.fetch(:page, DEFAULT_PAGE),
      per_page: params.fetch(:per_page, DEFAULT_PER_PAGE),
      order: params.fetch(:order, { id: :desc })
    }
  end
end
