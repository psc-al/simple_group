module UrlHelpers
  def stub_url_health_check(url, healthy: true, ending_url: nil)
    uri = URI.parse(url)
    service = UrlHealthCheckService.new(uri)
    allow(UrlHealthCheckService).to receive(:new).with(uri).and_return(service)
    allow(service).to receive(:healthy?).and_return(healthy)
    if ending_url.present?
      allow(service).to receive(:ending_uri).and_return(URI.parse(ending_url))
    end
  end
end
