require "support/page_objects/page_base"

module Admin
  class RemoveSubmissionPage < PageBase
    def initialize(submission)
      @submission = submission
    end

    def visit(as:)
      login_as(as)
      super(new_admin_submission_removal_path(submission_removal: { submission_short_id: submission.short_id }))
      self
    end

    def select_reason(reason)
      select reason, from: :submission_removal_reason
      self
    end

    def fill_in_details(details)
      fill_in :submission_removal_details, with: details
      self
    end

    def submit_form
      click_on "Remove Submission"
    end

    private

    attr_reader :submission
  end
end
