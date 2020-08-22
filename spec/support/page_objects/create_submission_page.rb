require "support/page_objects/page_base"

class CreateSubmissionPage < PageBase
  def visit(as:)
    login_as(as) if as.present?
    super(new_submission_path)
    self
  end

  def fill_in_title(str)
    fill_in :create_submission_form_title, with: str
    self
  end

  def fill_in_url(str)
    fill_in :create_submission_form_url, with: str
    self
  end

  def select_tag(tag_name)
    select tag_name, from: t("simple_form.labels.create_submission_form.tag_ids")
    self
  end

  def click_link_tab
    within("div#type-selector") do
      find("label", text: t("submissions.new.link_type")).click
    end
    self
  end

  def click_text_tab
    within("div#type-selector") do
      find("label", text: t("submissions.new.text_type")).click
    end
    self
  end

  def fill_in_body(str)
    fill_in :create_submission_form_body, with: str
    self
  end

  def check_original_author
    check :create_submission_form_original_author
    self
  end

  def submit_form
    within("form#new_create_submission_form") do
      click_on t("helpers.submit.create_submission_form.create")
    end
    self
  end

  def has_submission_body_text_box?
    has_css?("#body_wrapper", visible: true)
  end

  def has_submission_url_text_box?
    has_css?("#url_wrapper", visible: true)
  end

  def has_title_missing_error?
    has_client_side_error?("#create_submission_form_title", "Please fill out this field.")
  end

  def has_title_too_short_error?(char_num)
    has_client_side_error?(
      "#create_submission_form_title",
      "Please lengthen this text to 10 characters or more (you are currently using #{char_num} characters)."
    )
  end

  def has_title_with_x_chars?(char_num)
    page.find("#create_submission_form_title").value.length == char_num
  end

  def has_url_xor_body_error?
    has_error?(t("submissions.new.error.url_or_body"))
  end

  def has_missing_tags_error?
    has_client_side_error?("#tag-select", "Please select an item in the list.")
  end

  def has_tags_max_error?
    has_error?(t("submissions.new.error.tags_max"))
  end

  def has_tag_media_error?
    has_error?(t("submissions.new.error.tag_media"))
  end

  def has_banned_domain_error?(domain)
    has_error?(t("submissions.new.error.banned_domain", domain: domain))
  end

  def has_invalid_url_error?(url)
    has_error?(t("url.error.invalid", url: url))
  end

  def has_invalid_url_scheme_error?(scheme)
    has_error?(t("url.error.scheme", scheme: scheme))
  end

  def has_url_health_error?
    has_error?(t("submissions.new.error.url_health"))
  end

  def has_existing_submission_for_url_error?
    has_error?(t("submissions.new.error.url_exists"))
  end

  def has_rate_limit_error?(try_again_min)
    has_error?(t("submissions.new.error.rate_limit", try_again_min: try_again_min))
  end

  def has_error?(error)
    within("form#new_create_submission_form") do
      has_css?("span.error", text: error)
    end
  end

  def has_client_side_error?(field, message)
    page.find(field).native.attribute("validationMessage") == message
  end
end
