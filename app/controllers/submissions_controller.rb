class SubmissionsController < ApplicationController
  before_action :authenticate_user!, only: [:new, :create]

  def index
    @paginator = FlattenedSubmissionSearch.
      new(submission_search_params, current_user).
      results_paginator
  end

  def show
    @submission = FlattenedSubmissionSearch.new({}, current_user).
      by_short_id(params[:short_id])
    @root_comment = Comment.new
    @comments_by_parent = @submission.
      flattened_comments.
      with_voting_information_for(current_user).
      order(:id).
      group_by(&:parent_id)
  end

  def new
    @form = CreateSubmissionForm.new({}, current_user)
  end

  def create
    @form = CreateSubmissionForm.new(create_submission_params, current_user)
    if @form.save
      Vote.upvote.create!(votable: @form.submission, user: current_user)
      redirect_to submission_path(@form.submission.short_id)
    else
      render :new
    end
  end

  private

  def create_submission_params
    params.require(:create_submission_form).
      permit(:url, :title, :body, :original_author, tag_ids: [])
  end

  def submission_search_params
    params.permit(:page, :per_page, :tag_id, :username).to_h.symbolize_keys
  end
end
