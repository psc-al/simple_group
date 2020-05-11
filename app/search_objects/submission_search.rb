class SubmissionSearch
  DEFAULT_PAGE = 0
  DEFAULT_PER_PAGE = 25

  def initialize(params)
    @params = params
  end

  def results_paginator
    ResultsPaginator.new(scope, pagination_params)
  end

  private

  attr_reader :params

  def scope
    Submission.preload(:user, :domain)
  end

  def pagination_params
    {
      page: params.fetch(:page, DEFAULT_PAGE),
      per_page: params.fetch(:per_page, DEFAULT_PER_PAGE),
      order: { id: :desc }
    }
  end
end
