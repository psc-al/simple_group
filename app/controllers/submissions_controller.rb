class SubmissionsController < ApplicationController
  def index
    @paginator = SubmissionSearch.new(submission_search_params).results_paginator
  end

  private

  def submission_search_params
    params.permit(:page, :per_page)
  end
end
