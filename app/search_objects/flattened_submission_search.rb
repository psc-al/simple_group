# frozen_string_literal: true

class FlattenedSubmissionSearch
  DEFAULT_PAGE = 0
  DEFAULT_PER_PAGE = 25

  def initialize(params, user)
    @params = params
    @user = user
  end

  def by_short_id(short_id)
    base_relation(include_hidden: true).friendly.find(short_id)
  end

  def results_paginator
    ResultsPaginator.new(filtered_relation, pagination_params)
  end

  private

  attr_reader :params, :user

  def filtered_relation
    if params.empty?
      base_relation
    else
      base_relation.
        then { |rel| filter_by_tag(rel) }.
        then { |rel| filter_by_user(rel) }
    end
  end

  def filter_by_tag(rel)
    if params[:tag_id].present?
      rel.joins(:submission_tags).where(submission_tags: { tag_id: params[:tag_id] })
    else
      rel
    end
  end

  def filter_by_user(rel)
    if params[:username].present?
      rel.where(submitter_username: params[:username])
    else
      rel
    end
  end

  def base_relation(include_hidden: false)
    FlattenedSubmission.preload(:tags).then { |rel|
      if user.present?
        with_action_info(rel, include_hidden)
      else
        rel.select("flattened_submissions.*, NULL AS hidden_action_id, NULL AS saved_action_id")
      end
    }.with_voting_information_for(user)
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
