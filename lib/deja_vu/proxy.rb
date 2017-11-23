require "net/http"
require "net/https"
require "uri"

module DejaVu
  class Proxy
    DEFAULT_URI = "http://localhost:9292"
    DEFAULT_INTERACTION_DIR = nil

    attr_reader(
      :uri,
      :interactions_dir,
    )

    def initialize(
      uri: DEFAULT_URI,
      interactions_dir: DEFAULT_INTERACTION_DIR
    )
      @uri = URI(uri)
      @interactions_dir = interactions_dir
      yield self if block_given?
    end

    def expects(entries)
      RemoteExpectation.new(client: self, entries: entries)
    end

    def reset
      request(endpoint: "/api/reset", payload: {})
    end

    def request(endpoint:, payload:)
      request_uri = URI.join(uri, endpoint)

      http = Net::HTTP.new(request_uri.hostname, request_uri.port)
      http.use_ssl = true if uri.scheme == "https"
      http.post(request_uri.path, payload.to_json, "Content-Type" => "application/json")
    end
  end

  class RemoteExpectation
    def initialize(client:, entries:)
      @client = client
      @entries = entries
    end

    def to_return(body:, headers: {}, status: 200)
      @client.request(
        endpoint: "/api/expectations",
        payload: {
          entries: @entries,
          response: {
            body: body,
            headers: headers,
            status: status,
          }
        }
      )
    end

    def to_return_recorded_interaction(name)
      path = File.join([@client.interactions_dir, "#{name}.json"].compact)
      json = File.read(path)

      to_return(
        body: json["body"],
        headers: json["headers"],
        status: json["status"],
      )
    end
  end
  private_constant(:RemoteExpectation)
end
