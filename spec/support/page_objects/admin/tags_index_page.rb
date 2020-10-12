require "support/page_objects/page_base"

module Admin
  class TagsIndexPage < PageBase
    def visit(as:)
      login_as(as)
      super(admin_tags_path)
      self
    end

    def click_add_topic_tag
      click_link "+ Add topic tag"
      self
    end

    def has_tag_table_row?(tag)
      within find(".#{tag.kind}-tag-table") do
        has_css?("tbody tr td", text: tag.id)
      end
    end
  end
end
