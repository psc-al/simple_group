module PaginationComponent
  def has_next_page?
    within(".pagination-controls") do
      has_css?("span.pagination-forward")
    end
  end

  def has_previous_page?
    within(".pagination-controls") do
      has_css?("span.pagination-back")
    end
  end

  def next_page
    within(".pagination-controls") do
      click_link t("shared.pagination_controls.next_page")
    end
  end

  def previous_page
    within(".pagination-controls") do
      click_link t("shared.pagination_controls.previous_page")
    end
  end
end
