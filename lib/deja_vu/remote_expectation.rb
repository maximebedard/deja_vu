require "net/http"
require "net/https"
require "uri"

module DejaVu
  module RemoteExpectation
    DEFAULT_PROXY_URI = "http://localhost:9292"

    def self.proxy_uri
      @@proxy_uri ||= DEFAULT_PROXY_URI
    end

    def self.proxy_uri=(value)
      @@proxy_uri = value
    end

    def self.interactions_dir
      @@interactions_dir ||= nil
    end

    def self.interactions_dir=(value)
      @@interactions_dir = value
    end

    def expects_proxy(entries)
      Proxy.new(entries)
    end

    private

    class Proxy
      attr_reader(:entries)

      def initialize(entries)
        @entries = entries
      end

      def to_return(body:, headers: {}, status: 200)
        json_request(
          entries: entries,
          response: {
            body: body,
            headers: headers,
            status: status,
          }
        )
      end

      def to_return_recorded_interaction(name)
        path = File.join([RemoteExpectation.interactions_dir, "#{name}.json"].compact)
        json = File.read(path)

        to_return(
          body: json["body"],
          headers: json["headers"],
          status: json["status"],
        )
      end

      private

      def json_request(params)
        uri = URI.join(RemoteExpectation.proxy_uri, "/api/expectations")

        http = Net::HTTP.new(uri.hostname, uri.port)
        http.use_ssl = true if uri.scheme == "https"
        http.post(uri.path, params.to_json, "Content-Type" => "application/json")
      end
    end
  end
end
