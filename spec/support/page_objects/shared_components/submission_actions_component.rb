module SubmissionActionsComponent
  def save_submission(submission)
    within find(:css, "##{submission.short_id}") do
      click_link t("submissions.submission_list_item.actions.default.saved")
    end
  end

  def hide_submission(submission)
    within find(:css, "##{submission.short_id}") do
      click_link t("submissions.submission_list_item.actions.default.hidden")
    end
  end

  def has_hidden_submission?(submission)
    has_css?("##{submission.short_id}.submission-hidden") &&
      has_hidden_submission_link?(submission)
  end

  def has_hidden_submission_link?(submission)
    has_submission_action_link?(submission, :hidden)
  end

  def has_saved_submission?(submission)
    has_css?("##{submission.short_id}.submission-saved") &&
      has_submission_action_link?(submission, :saved)
  end

  def has_save_submission_link?(submission)
    within find(:css, "##{submission.short_id}") do
      has_css?("a", text: t("submissions.submission_list_item.actions.default.saved"))
    end
  end

  def has_hide_submission_link?(submission)
    within find(:css, "##{submission.short_id}") do
      has_css?("a", text: t("submissions.submission_list_item.actions.default.hidden"))
    end
  end

  private

  def has_submission_action_link?(submission, kind)
    within find(:css, "##{submission.short_id}") do
      has_link? t("submissions.submission_list_item.actions.created.#{kind}")
    end
  end
end
