# frozen_string_literal: true

# this should probably be revisted sometime in the
# near future
class CreateSubmissionForm
  include ActiveModel::Model

  MODEL_NAME = "CreateSubmissionForm"
  I18N_PREFIX = "submissions.new.error"

  validates :title, presence: { message: I18n.t("#{I18N_PREFIX}.title_missing") },
    length: { in: (10..175), message: I18n.t("#{I18N_PREFIX}.title_length") }
  validate :url_xor_body
  validate :domain_and_url_valid, if: ->(f) { f.url.present? && f.body.blank? }

  def initialize(params, user)
    stripped_params = params.each_value(&:strip!).select { |_, v| v.present? }
    @user = user
    super(stripped_params)
  end

  def save
    @submission = initialize_submission
    if valid?
      @submission.url = url if url.present?
      @submission.domain = domain if domain.present?
      @submission.save
    end
  end

  attr_accessor :title, :url, :domain, :body, :original_author, :user, :submission

  private

  def initialize_submission
    Submission.new(
      title: title,
      body: body,
      original_author: original_author.to_i.eql?(1),
      user: user
    )
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
end
