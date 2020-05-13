RSpec.describe UrlHealthCheckService do
  describe "#healthy?" do
    context "when the given URI's scheme is https" do
      context "when the request is valid over https" do
        it "returns true" do
          url = "https://example.com"
          stub_check_response(url)
          uri = URI.parse(url)

          service = UrlHealthCheckService.new(uri)

          expect(service).to be_healthy
          expect(service.ending_uri).to eq(uri)
        end
      end

      context "when the request is not valid over https" do
        it "returns false" do
          url = "https://example.com"
          stub_check_response(url, status: 500)
          uri = URI.parse(url)

          service = UrlHealthCheckService.new(uri)

          expect(service).not_to be_healthy
        end
      end
    end

    context "when the given URI's scheme is http" do
      it "checks to see if the request would be valid over https and returns true if valid" do
        url = "http://example.com"
        https_url = "https://example.com"
        stub_check_response(https_url)
        uri = URI.parse(url)

        service = UrlHealthCheckService.new(uri)

        expect(service).to be_healthy
        expect(service.ending_uri).to eq(URI.parse(https_url))
      end

      it "returns true if the request is not valid over https but valid over http" do
        url = "http://example.com"
        https_url = "https://example.com"
        stub_check_response(url)
        stub_check_response(https_url, status: 500)
        uri = URI.parse(url)

        service = UrlHealthCheckService.new(uri)

        expect(service).to be_healthy
        expect(service.ending_uri).to eq(uri)
      end

      it "returns false when the request is valid over neither http nor https" do
        url = "http://example.com"
        https_url = "https://example.com"
        stub_check_response(url, status: 500)
        stub_check_response(https_url, status: 500)
        uri = URI.parse(url)

        service = UrlHealthCheckService.new(uri)

        expect(service).not_to be_healthy
      end
    end

    context "when there are redirects" do
      context "when there are 10 or less redirects" do
        it "returns true if the final response is valid and updates the `ending_uri` to its URI" do
          # this is something you'll see often
          url = "https://example.com"
          www_url = "https://www.example.com"
          stub_check_response(url, status: 302, headers: { "location" => www_url })
          stub_check_response(www_url, status: 200)

          uri = URI.parse(url)

          service = UrlHealthCheckService.new(uri)

          expect(service).to be_healthy
          expect(service.ending_uri).to eq(URI.parse(www_url))
        end

        it "returns false if the final response is invalid" do
          url = "https://example.com"
          www_url = "https://www.example.com"
          stub_check_response(url, status: 302, headers: { "location" => www_url })
          stub_check_response(www_url, status: 500)

          uri = URI.parse(url)

          service = UrlHealthCheckService.new(uri)

          expect(service).not_to be_healthy
        end
      end

      context "when there are more than 10 redirects" do
        it "returns false" do
          url = "https://example.com"
          www_url = "https://www.example.com"
          # I'm being a troll and causing an infinite redirect
          stub_check_response(url, status: 302, headers: { "location" => www_url })
          stub_check_response(www_url, status: 302, headers: { "location" => url })

          uri = URI.parse(url)

          service = UrlHealthCheckService.new(uri)

          expect(service).not_to be_healthy
        end
      end
    end

    context "when the given URI's scheme is neither https nor http" do
      it "returns false" do
        uri = URI.parse("ftp://ftp.foo.com")

        expect { UrlHealthCheckService.new(uri).healthy? }.to raise_error("unsupported URI scheme")
      end
    end

    context "when the URI involves an IP address" do
      it "returns false" do
        uri = URI.parse("http://192.168.1.1")

        expect(UrlHealthCheckService.new(uri)).not_to be_healthy
      end
    end
  end
end

def stub_check_response(url, status: 200, headers: {}, body: "")
  stub_request(:get, url).to_return(body: body, headers: headers, status: status)
end
