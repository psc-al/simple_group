class SubmissionsController < ApplicationController
  before_action :authenticate_user!, only: [:new, :create]

  def index
    @paginator = SubmissionSearch.new(submission_search_params).results_paginator
  end

  def show
    @submission = Submission.preload(:user, :domain).find(params[:id])
  end

  def new
    @form = CreateSubmissionForm.new({}, current_user)
  end

  def create
    @form = CreateSubmissionForm.new(create_submission_params, current_user)
    if @form.save
      redirect_to submission_path(@form.submission.id)
    else
      render :new
    end
  end

  private

  def create_submission_params
    params.require(:create_submission_form).permit(:url, :title, :body, :original_author)
  end

  def submission_search_params
    params.permit(:page, :per_page)
  end
end
