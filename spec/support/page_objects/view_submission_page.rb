require "support/page_objects/page_base"

class ViewSubmissionPage < PageBase
  def visit(submission, as:)
    login_as(as) if as.present?
    super(submission_path(submission.id))
    self
  end

  def has_correct_submission_link?(submission)
    url = submission.url.presence || submission_path(submission.short_id)

    within find(".submission-link") do
      has_link?(submission.title, href: url)
    end
  end

  def has_authored_by?(user)
    within find(".submission-line2") do
      has_css?(".submission-info", text: t("submissions.submission_list_item.authored_by")) &&
        has_css?(".submission-user a", text: user.username)
    end
  end

  def has_submitted_by?(user)
    within find(".submission-line2") do
      has_css?(".submission-info", text: t("submissions.submission_list_item.submitted_by")) &&
        has_css?(".submission-user a", text: user.username)
    end
  end

  def has_plain_text_submission_body?(body)
    within find(".submission-body") do
      has_css?("p", text: body)
    end
  end

  def has_tag?(tag)
    has_css?(".tag_#{tag.kind}", text: tag.id)
  end
end
