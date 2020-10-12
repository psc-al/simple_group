require "support/page_objects/page_base"
require "support/page_objects/shared_components/admin/tag_form"

module Admin
  class EditTagPage < PageBase
    include TagForm

    def initialize(tag)
      @tag = tag
    end

    def visit(as:)
      login_as(as)
      super(edit_admin_tag_path(tag))
      self
    end

    def submit_form
      within("form#edit_tag_#{tag.id}") do
        click_on "Update Tag"
      end
      self
    end

    private

    attr_reader :tag
  end
end
