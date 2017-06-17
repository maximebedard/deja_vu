require "net/http"
require "net/https"
require "uri"

module DejaVu
  module ProxyHelper
    def self.proxy_uri
      @@proxy_uri ||= "localhost:9292"
    end

    def self.proxy_uri=(value)
      @@proxy_uri = value
    end

    def self.interactions_dir
      @@interactions_dir
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
        path = File.join([ProxyHelper.interactions_dir, name, ".json"].compact)
        json = File.read(path)

        to_return(
          body: json["body"],
          headers: json["headers"],
          status: json["status"],
        )
      end

      private

      def json_request(params)
        uri = ProxyHelper.proxy_uri
        uri = URI(uri) unless uri.is_a?(URI)
        require "pry-byebug"; binding.pry;
        req = Net::HTTP::Post.new(uri, "Content-Type" => "application/json")
        req.body = params.to_json

        Net::HTTP.start(uri.hostname, uri.port) { |http| http.request(req) }
      end
    end
  end
end
