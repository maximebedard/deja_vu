require "test_helper"

module DejaVu
  class RequestSerializerTest < Minitest::Test
    def setup
      @env = Rack::MockRequest.env_for("http://example.com:8080/", {"REMOTE_ADDR" => "10.10.10.10"})
      @request = Rack::Request.new(@env)
    end

    def test_serialization
      assert_equal(
        {
          "path" => "/",
          "method" => "GET",
          "body" => "",
          "params" => {},
        },
        RequestSerializer.call(@request),
      )
    end

    def test_serialization_with_params
      @env[Rack::PATH_INFO] = "/api/expectations"
      @env[Rack::RACK_INPUT] = StringIO.new("allo")
      @env[Rack::RACK_INPUT].set_encoding(Encoding::BINARY)
      # @env[Rack::RACK_REQUEST_QUERY_HASH] = {a: "a", b: 1}

      assert_equal(
        {
          "path" => "/api/expectations",
          "method" => "GET",
          "body" => "allo",
          "params" => {},
          # params: {a: "b", b: 1},
        },
        RequestSerializer.call(@request),
      )
    end
  end
end
