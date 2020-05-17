require "support/page_objects/page_base"
require "support/page_objects/shared_components/pagination_component"
require "support/page_objects/shared_components/submission_actions_component"

class SubmissionsIndexPage < PageBase
  include PaginationComponent
  include SubmissionActionsComponent

  def visit(as: nil)
    login_as(as) if as.present?

    super submissions_path
  end

  def has_submission_row_for?(submission)
    has_css?("##{submission.short_id}") &&
      has_correct_submission_info?(submission)
  end

  def has_correct_submission_info?(submission)
    within find("##{submission.short_id}") do
      has_proper_submission_link?(submission) &&
        has_css?(".submission-user", text: submission.user.username) &&
        has_submission_tags?(submission)
    end
  end

  def has_proper_submission_link?(submission)
    url = submission.url.presence || submission_path(submission.short_id)

    has_link?(submission.title, href: url)
  end

  def has_submission_tags?(submission)
    submission.tags.each do |tag|
      has_css?(".tag_#{tag.kind}", text: tag.id)
    end
  end
end
