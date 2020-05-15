# frozen_string_literal: true

# this should probably be revisted sometime in the
# near future
class CreateSubmissionForm
  include ActiveModel::Model

  MODEL_NAME = "CreateSubmissionForm"
  I18N_PREFIX = "submissions.new.error"

  validates :title, presence: { message: I18n.t("#{I18N_PREFIX}.title_missing") },
    length: { in: (10..175), message: I18n.t("#{I18N_PREFIX}.title_length") }
  validates :tag_ids, presence: { message: I18n.t("#{I18N_PREFIX}.tags_missing") },
    length: { maximum: 5, message: I18n.t("#{I18N_PREFIX}.tags_max") }
  validate :tag_kinds_valid, if: ->(f) { f.tag_ids.present? }
  validate :url_xor_body
  validate :domain_and_url_valid, if: ->(f) { f.url.present? && f.body.blank? }
  validate :validate_user_can_submit

  def initialize(params, user)
    stripped_and_present_params = strip_params(params).
      merge(tag_ids: params[:tag_ids].to_a.select(&:present?))
    @user = user
    super(stripped_and_present_params)
  end

  def save
    @submission = initialize_submission
    if valid?
      ApplicationRecord.transaction do
        @submission.url = url if url.present?
        @submission.domain = domain if domain.present?
        @submission.save!
        user.update_last_submission_at!
      end
    end
  end

  attr_accessor :title, :url, :tag_ids, :domain, :body, :original_author, :user, :submission

  private

  def strip_params(params)
    params.each_value { |v| v.respond_to?(:strip!) ? v.strip! : v }.select { |_, v| v.present? }
  end

  def initialize_submission
    Submission.new(
      title: title,
      body: body,
      original_author: original_author.to_i.eql?(1),
      user: user,
      tags: tags
    )
  end

  def tags
    @_tags ||= Tag.where(id: tag_ids)
  end

  def url_xor_body
    unless url.present? ^ body.present?
      errors.add(:base, I18n.t("#{I18N_PREFIX}.url_or_body"))
    end
  end

  def domain_and_url_valid
    cleaned_url_result = UrlParser.parse(url)
    if cleaned_url_result[:status] == :ok
      validate_and_assign_domain(cleaned_url_result[:host])
      validate_and_set_url(cleaned_url_result[:url]) unless domain.banned?
    else
      errors.add(:url, cleaned_url_result[:error])
    end
  end

  def validate_and_assign_domain(domain_name)
    @domain = Domain.find_or_initialize_by(name: domain_name)
    if domain.banned?
      errors.add(:domain, I18n.t("#{I18N_PREFIX}.banned_domain", domain: domain.name))
    end
  end

  def validate_and_set_url(cleaned_url)
    uri = URI.parse(cleaned_url)
    health_checker = UrlHealthCheckService.new(uri)
    if health_checker.healthy?
      ending_uri = health_checker.ending_uri
      if uri != ending_uri
        assign_domain_and_url_from_healthcheck_ending_uri(ending_uri)
      else
        @url = cleaned_url
      end
      check_for_existing_submission
    else
      errors.add(:url, I18n.t("#{I18N_PREFIX}.url_health"))
    end
  end

  def assign_domain_and_url_from_healthcheck_ending_uri(ending_uri)
    # we were redirected to a different URL so we need to re-validate
    # that everything is allowed / cleaned up.
    cleaned_url_result = UrlParser.parse(ending_uri.to_s)
    if cleaned_url_result[:status] == :ok
      validate_and_assign_domain(cleaned_url_result[:host])
      @url = cleaned_url_result[:url]
    else
      errors.add(:url, cleaned_url_result[:error])
    end
  end

  def check_for_existing_submission
    errors.add(:url, I18n.t("#{I18N_PREFIX}.url_exists")) if Submission.where(url: url).exists?
  end

  def validate_user_can_submit
    try_again_min = user.minutes_until_next_submission
    unless try_again_min.zero?
      errors.add(:user, I18n.t("#{I18N_PREFIX}.rate_limit", try_again_min: try_again_min))
    end
  end

  def tag_kinds_valid
    validate_tags_accessible_for_user
    validate_at_least_one_non_media_tag
  end

  def validate_tags_accessible_for_user
    unless tags.none?(&:mod?) || (user.moderator? || user.admin?)
      errors.add(:tag_ids, I18n.t("#{I18N_PREFIX}.tag_forbidden"))
    end
  end

  def validate_at_least_one_non_media_tag
    unless tags.any? { |t| !t.media? }
      errors.add(:tag_ids, I18n.t("#{I18N_PREFIX}.tag_media"))
    end
  end
end
