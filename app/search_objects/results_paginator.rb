class ResultsPaginator
  MAX_PER_PAGE = 100

  def initialize(scope, params)
    @scope = scope
    @page = [params.fetch(:page).to_i, MAX_PER_PAGE].min
    @per_page = params.fetch(:per_page)
    @order = params.fetch(:order, { id: :asc })
    @count_field = params.fetch(:count_field, :id)
  end

  def results_page
    scope.
      order(order).
      offset(offset).
      limit(per_page)
  end

  def max_page
    (scope.count(count_field).to_f / per_page).ceil - 1
  end

  def offset
    if page.zero?
      0
    else
      page * per_page
    end
  end

  attr_reader :page, :per_page, :order, :count_field

  private

  attr_reader :scope
end
