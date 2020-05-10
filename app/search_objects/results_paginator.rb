class ResultsPaginator
  MAX_PER_PAGE = 100

  def initialize(scope, params)
    @scope = scope
    @page = [params.fetch(:page).to_i, MAX_PER_PAGE].min
    @per_page = params.fetch(:per_page)
    @order = params.fetch(:order, { id: :asc })
  end

  def results_page
    scope.
      order(order).
      offset(offset).
      limit(per_page)
  end

  def max_page
    (scope.count.to_f / per_page).ceil - 1
  end

  def offset
    if page.zero?
      0
    else
      page * per_page
    end
  end

  attr_reader :page, :per_page, :order

  private

  attr_reader :scope
end
