RSpec.describe UrlParser do
  describe ".parse" do
    it "parses the URL and returns a result hash containing a cleaned URL and other info" do
      url = "https://www.foo.com/path/to/article?utm_medium=1&foo=bar#bop"

      expect(UrlParser.parse(url)).to eq(
        {
          scheme: "https",
          userinfo: nil,
          host: "foo.com",
          port: nil,
          path: "/path/to/article",
          query: "foo=bar",
          fragment: "bop",
          url: "https://foo.com/path/to/article?foo=bar#bop",
          status: :ok
        }
      )
    end

    context "when it's a wwwx prepended url" do
      it "parses the URL without error" do
        expect(UrlParser.parse("https://www.foo.com")).to include(url: "https://foo.com")
        expect(UrlParser.parse("https://www2.foo.com")).to include(url: "https://foo.com")
        expect(UrlParser.parse("https://www3.foo.com")).to include(url: "https://foo.com")
      end
    end

    context "when there is userinfo in the url" do
      it "keeps it in the result" do
        expect(UrlParser.parse("https://bar@www.foo.com")).to include(url: "https://bar@foo.com")
      end
    end

    context "when there is a port present" do
      context "when the scheme is http and the port is 80" do
        it "removes the port from the result" do
          expect(UrlParser.parse("http://www.foo.com:80")).to include(url: "http://foo.com")
        end
      end

      context "when the scheme is https and the port is 443" do
        it "removes the port from the result" do
          expect(UrlParser.parse("https://www.foo.com:443")).to include(url: "https://foo.com")
        end
      end

      context "when the port is neither 80 nor 443" do
        it "appends the port to the result" do
          expect(UrlParser.parse("http://www.foo.com:666")).to include(url: "http://foo.com:666")
          expect(UrlParser.parse("https://www.foo.com:666")).to include(url: "https://foo.com:666")
        end
      end
    end

    context "when there are query parameters" do
      context "when there are tracker query parameters" do
        it "removes the trackers from the result and leaves the rest" do
          expect(UrlParser.parse("https://www.foo.com?utm_source=1&foo=bar")).
            to include(url: "https://foo.com?foo=bar")
        end
      end
    end

    context "when there is a fragment" do
      it "includes it in the result" do
        expect(UrlParser.parse("https://www.foo.com#bar")).to include(url: "https://foo.com#bar")
      end
    end

    context "when the URL has an unaccepted scheme or scheme is missing" do
      it "returns a hash with an error message" do
        expect(UrlParser.parse("ftp://user@host/foo")).to eq({
          status: :error,
          error: I18n.t("url.error.scheme", scheme: "ftp")
        })

        expect(UrlParser.parse("foo.com")).to eq({
          status: :error,
          error: I18n.t("url.error.scheme", scheme: nil)
        })
      end
    end

    context "when the URL has nothing but a scheme (first of all, wtf)" do
      it "returns a hash with an error message" do
        expect(UrlParser.parse("http://")).to eq({
          status: :error,
          error: I18n.t("url.error.invalid", url: "http://")
        })
      end
    end
  end
end
