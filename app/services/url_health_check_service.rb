# frozen_string_literal: true

require "resolv"

# this is definitely not as robust as it can, and maybe should be
# I welcome anyone to expand on it or re-approach it entirely.
class UrlHealthCheckService
  def initialize(base_uri)
    @base_uri = base_uri
    @ending_uri = base_uri
  end

  def healthy?
    # I find it odd that anyone would submit a literal IP.
    # Given that the underlying IPs can change while the
    # URL may stay the same, I'm opting to reject IPs
    # entirely.
    not_an_ip? && healthy_response_or_redirect?
  end

  attr_reader :base_uri, :ending_uri

  private

  def not_an_ip?
    (Resolv::IPv4::Regex =~ base_uri.host).nil? &&
      (Resolv::IPv6::Regex =~ base_uri.host).nil?
  end

  def healthy_response_or_redirect?
    case base_uri.scheme
    when "https"
      healthy_over_ssl?(base_uri)
    when "http"
      # try with SSL just in case the user forgot to specifiy
      https_uri = base_uri.dup.tap { |uri| uri.scheme = "https" }.then { |uri| URI.parse(uri.to_s) }
      healthy_over_ssl?(https_uri) || healthy_response?(base_uri)
    else
      raise "unsupported URI scheme"
    end
  end

  def healthy_over_ssl?(uri)
    # this is an incredibly naive check. basically, if there is something
    # insanely wrong, we'll encounter a Faraday SSL error
    uri.scheme == "https" && healthy_response?(uri)
  end

  def healthy_response?(uri)
    response = Faraday.get(uri)
    if response.success?
      @ending_uri = uri
      true
    else
      healthy_redirect?(response)
    end
  rescue Faraday::ConnectionFailed, Faraday::SSLError, Faraday::TimeoutError, OpenSSL::SSL::SSLError
    # if any of the above happen then the URL is considered unhealthy. We don't
    # care why. At this point the user should verify it's formatted correctly
    # and that the file exists at the location
    false
  end

  def healthy_redirect?(response, limit = 10)
    if limit.zero?
      false
    else
      is_redirect?(response) && succeeds_in_redirection?(response, limit)
    end
  end

  def succeeds_in_redirection?(response, limit)
    location = response.headers["location"]
    redirect_response = Faraday.get(URI.parse(location)) if location.present?
    if redirect_response.present? && redirect_response.success?
      # save the redirect uri so we / the client can just go straight to the
      # resource in the future
      @ending_uri = URI.parse(location)
      true
    else
      healthy_redirect?(redirect_response, limit - 1)
    end
  end

  def is_redirect?(response)
    # I realize that some of these redirect codes we don't care about in practice
    # but this is a lot neater than enumerating them all
    (300..308).include?(response.status)
  end
end
