# frozen_string_literal: true

module SubmissionsHelper
  def submission_href_for(submission)
    submission.url.presence || submission_path(submission.short_id)
  end

  def submitted_by_text(submission)
    if submission.original_author?
      t("submissions.submission_list_item.authored_by")
    else
      t("submissions.submission_list_item.submitted_by")
    end
  end

  def submitted_time_text(submission)
    "#{time_ago_in_words(submission.created_at)} #{t('submissions.submission_list_item.ago')}"
  end

  def tag_select_options(user)
    Tag.for_user(user).order(:id).all.map do |tag|
      [tag.id, tag.id]
    end
  end

  def submission_classes_for(submission, without_action_classes: false)
    if without_action_classes
      ""
    else
      [saved_class_for(submission), hidden_class_for(submission)].join(" ")
    end
  end

  def saved_class_for(submission)
    if submission.saved_action_id.present?
      "submission-saved"
    else
      ""
    end
  end

  def hidden_class_for(submission)
    if submission.hidden_action_id.present?
      "submission-hidden"
    else
      ""
    end
  end

  def save_link_text_for(submission)
    if submission.saved_action_id.present?
      t("submissions.submission_list_item.actions.created.saved")
    else
      t("submissions.submission_list_item.actions.default.saved")
    end
  end

  def hide_link_text_for(submission)
    if submission.hidden_action_id.present?
      t("submissions.submission_list_item.actions.created.hidden")
    else
      t("submissions.submission_list_item.actions.default.hidden")
    end
  end
end
