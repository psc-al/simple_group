require "support/page_objects/page_base"
require "support/page_objects/shared_components/pagination_component"

class SubmissionsIndexPage < PageBase
  include PaginationComponent

  def visit(as: nil)
    login_as(as) if as.present?

    super submissions_path
  end

  def has_submission_row_for?(submission)
    has_css?("#submission_#{submission.id}") &&
      has_correct_submission_info?(submission)
  end

  def has_correct_submission_info?(submission)
    within find("#submission_#{submission.id}") do
      has_proper_submission_link?(submission) &&
        has_css?(".submission-user", text: submission.user.username)
    end
  end

  def has_proper_submission_link?(submission)
    url = submission.url.presence || submission_path(submission.id)

    has_link?(submission.title, href: url)
  end
end
