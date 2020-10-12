require "support/page_objects/page_base"
require "support/page_objects/shared_components/admin/tag_form"

module Admin
  class CreateTagPage < PageBase
    include TagForm

    def visit(as:)
      login_as(as)
      super(new_admin_tag_path)
      self
    end

    def submit_form
      within("form#new_tag") do
        click_on "Create Tag"
      end
      self
    end
  end
end
