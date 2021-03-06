require "test_helper"

module DejaVu
  class AppTest < Minitest::Test
    def setup
      @app = DejaVu::App.new
      @env = Rack::MockRequest.env_for("http://example.com:8080/", {"REMOTE_ADDR" => "10.10.10.10"})
    end

    def test_push_expectation
      request = {
        "query" => {},
        "response" => {
          "body" => "patate",
          "headers" => {},
          "status" => 200,
        }
      }
      @env[Rack::PATH_INFO] = "/api/expectations"
      @env[Rack::RACK_INPUT] = StringIO.new(request.to_json)
      @env[Rack::RACK_INPUT].set_encoding(Encoding::BINARY)
      @env["CONTENT_TYPE"] = "application/json"
      @env[Rack::REQUEST_METHOD] = "POST"

      status, headers, body = @app.call(@env)

      assert_equal(201, status)
      assert_equal({"Content-Type" => "application/json"}, headers)

      assert_equal(request["query"], @app.expectations[0].query)
      assert_equal(request["response"], @app.expectations[0].response)
    end

    def test_setup_strategy
      request = {
        "strategy" => "matches",
      }
      @env[Rack::PATH_INFO] = "/api/strategy"
      @env[Rack::RACK_INPUT] = StringIO.new(request.to_json)
      @env[Rack::RACK_INPUT].set_encoding(Encoding::BINARY)
      @env["CONTENT_TYPE"] = "application/json"
      @env[Rack::REQUEST_METHOD] = "POST"

      status, headers, body = @app.call(@env)

      assert_equal(200, status)
      assert_equal({"Content-Type" => "application/json"}, headers)
    end

    def test_clear_expectations
      @app.expectations = [1, 2, 3]
      request = {}

      @env[Rack::PATH_INFO] = "/api/expectations/clear"
      @env[Rack::RACK_INPUT] = StringIO.new(request.to_json)
      @env[Rack::RACK_INPUT].set_encoding(Encoding::BINARY)
      @env["CONTENT_TYPE"] = "application/json"
      @env[Rack::REQUEST_METHOD] = "POST"

      status, headers, body = @app.call(@env)

      assert_equal(200, status)
      assert_equal({"Content-Type" => "application/json"}, headers)
      assert_equal(["{}"], body)
      assert_empty(@app.expectations)
    end

    def test_setup_shitty_strategy
      request = {
        "strategy" => "poop",
      }
      @env[Rack::PATH_INFO] = "/api/strategy"
      @env[Rack::RACK_INPUT] = StringIO.new(request.to_json)
      @env[Rack::RACK_INPUT].set_encoding(Encoding::BINARY)
      @env["CONTENT_TYPE"] = "application/json"
      @env[Rack::REQUEST_METHOD] = "POST"

      status, headers, body = @app.call(@env)

      assert_equal(400, status)
      assert_equal(["strategy=poop does not exists."], body)
    end

    def test_shift_expectation_matches
      response = {"body" => "mobile", "headers" => {}, "status" => 200}
      expectation = make_expectation("patate", true, response)
      @app.expectations = [expectation]

      assert_equal(
        [response["status"], response["headers"], [response["body"]]],
        @app.call(@env)
      )
    end

    def test_shift_expectation_does_not_matches
      expectation = make_expectation("patate", false)
      @app.expectations = [expectation]

      assert_equal(
        [422, {}, ["expectation=patate did not match."]],
        @app.call(@env)
      )
    end

    def test_shift_expectation_empty
      assert_equal(
        [412, {}, ["no expectation set."]],
        @app.call(@env)
      )
    end

    def test_list_expectations
      @env[Rack::PATH_INFO] = "/api/expectations"
      @env["CONTENT_TYPE"] = "application/json"
      @env[Rack::REQUEST_METHOD] = "GET"

      expectation = make_expectation("patate", false)
      @app.expectations = [expectation]

      assert_equal(
        [200, {"Content-Type" => "application/json"}, [@app.expectations.to_json]],
        @app.call(@env)
      )
    end

    def test_list_expectations_empty
      @env[Rack::PATH_INFO] = "/api/expectations"
      @env["CONTENT_TYPE"] = "application/json"
      @env[Rack::REQUEST_METHOD] = "GET"

      assert_equal(
        [200, {"Content-Type" => "application/json"}, [@app.expectations.to_json]],
        @app.call(@env)
      )
    end

    private

    def make_expectation(token, matches, response = {})
      Struct.new(:token, :matches, :response) do
        def matches?(*)
          matches
        end
      end.new(token, matches, response)
    end
  end
end
