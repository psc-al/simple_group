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
end
