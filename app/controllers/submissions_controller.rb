class SubmissionsController < ApplicationController
  before_action :authenticate_user!, only: [:new, :create]

  def index
    @paginator = SubmissionSearch.new(submission_search_params, current_user).results_paginator
  end

  def show
    @submission = submission
  end

  def new
    @form = CreateSubmissionForm.new({}, current_user)
  end

  def create
    @form = CreateSubmissionForm.new(create_submission_params, current_user)
    if @form.save
      redirect_to submission_path(@form.submission.short_id)
    else
      render :new
    end
  end

  private

  def submission
    Submission.friendly.preload(:user, :domain).then { |rel|
      if current_user.present?
        rel.
          left_join_saved_info_for(current_user).
          left_join_hidden_info_for(current_user).
          select(%(
            submissions.*,
            hidden_actions.id AS hidden_action_id,
            saved_actions.id AS saved_action_id
          ).squish)
      else
        rel.select("submissions.*, NULL AS hidden_action_id, NULL AS saved_action_id")
      end
    }.find(params[:short_id])
  end

  def create_submission_params
    params.require(:create_submission_form).
      permit(:url, :title, :body, :original_author, tag_ids: [])
  end

  def submission_search_params
    params.permit(:page, :per_page)
  end
end
