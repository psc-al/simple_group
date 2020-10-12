require "support/page_objects/page_base"

module Admin
  class SubmissionRemovalsIndexPage < PageBase
    def visit(as:)
      login_as(as)
      super(admin_submission_removals_path)
      self
    end

    def undo_removal(removal)
      within find("#removal_#{removal.id}") do
        accept_confirm do
          click_on "Undo"
        end
      end
    end

    def has_removal_row?(removal)
      has_css?("#removal_#{removal.id}", wait: 0)
    end
  end
end
