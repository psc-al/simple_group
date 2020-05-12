# frozen_string_literal: true

class UrlParser
  def self.parse(url)
    new(url).parse if url.present?
  end

  def initialize(raw_url)
    @raw_url = raw_url
  end

  attr_reader :raw_url

  def parse
    # we're only allowing HTTP. If they try to give us something
    # else, or an otherwise invalid URI, we'll return `nil`.
    uri = URI.parse(raw_url)
    case uri
    when URI::HTTP, URI::HTTPS
      extract_data(uri)
    else
      { status: :error, error: I18n.t("url.error.scheme", scheme: uri.scheme) }
    end
  end

  private

  def extract_data(uri)
    initialize_parsed_attributes(uri).then do |attrs|
      # they need to at least give us a scheme and host
      if attrs[:scheme].present? && attrs[:host].present?
        build_result(attrs)
      else
        { status: :error, error: I18n.t("url.error.invalid", url: raw_url) }
      end
    end
  end

  def build_result(attrs)
    [
      "#{attrs[:scheme]}://",
      ("#{attrs[:userinfo]}@" if attrs[:userinfo].present?),
      (attrs[:host]).to_s,
      (":#{attrs[:port]}" if attrs[:port].present?),
      (attrs[:path]).to_s,
      ("?#{attrs[:query]}" if attrs[:query].present?),
      ("##{attrs[:fragment]}" if attrs[:fragment].present?)
    ].join.then { |url| attrs.merge(url: url, status: :ok) }
  end

  def initialize_parsed_attributes(uri)
    {
      scheme: uri.scheme,
      userinfo: uri.userinfo,
      host: clean_host(uri.host),
      port: maybe_port(uri.scheme, uri.port),
      path: uri.path,
      query: clean_query(uri.query),
      fragment: uri.fragment
    }
  end

  def clean_host(host)
    # removes `www\d?.` prefixes so that we don't treat the same page
    # different because one URL might have `www.` and the other
    # might not
    host.sub(/www\d?\./, "") if host.present?
  end

  def maybe_port(scheme, port)
    # remove common http / https ports from URL so that if we see the
    # URL without the port we don't consider it the same.
    unless scheme == "http" && port == 80 || scheme == "https" && port == 443
      port
    end
  end

  def clean_query(query)
    # remove creepy trackers
    # todo: expand on this
    if query.present?
      query.split("&").
        reject { |param| param.match(/^utm_(source|medium|campaign|term|content)=|^sk=|^fbclid=/) }.
        join("&")
    end
  end
end
