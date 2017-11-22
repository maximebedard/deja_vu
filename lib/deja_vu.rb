require "json"
require "securerandom"
require "rack/request"
require "deja_vu/expectation"
require "deja_vu/remote_expectation"
require "deja_vu/request_serializer"
require "deja_vu/version"

module DejaVu
  class App
    attr_accessor(
      :expectations,
      :strategy,
    )

    def initialize
      @expectations = []
      @strategy = COMPARE_STRATEGIES.fetch("shift")
    end

    def call(env)
      request = Rack::Request.new(env)

      if setup_strategy_request?(request)
        setup_strategy(request)
      elsif list_expectations?(request)
        list_expectations(request)
      elsif push_expectation?(request)
        push_expectation(request)
      else
        shift_expectation(request)
      end
    end

    private

    COMPARE_STRATEGIES = {
      "matches" => -> (expectations) { expectations },
      "shift" => -> (expectations) { expectations.shift },
    }

    def list_expectations?(request)
      request.path_info =~ %r{^/api/expectations} &&
        request.request_method == "GET" &&
        request.content_type == "application/json"
    end

    def list_expectations(request)
      [200, {"Content-Type" => "application/json"}, [@expectations.to_json]]
    end

    def push_expectation?(request)
      request.path_info =~ %r{^/api/expectations} &&
        request.request_method == "POST" &&
        request.content_type == "application/json"
    end

    def push_expectation(request)
      json = JSON.parse(request.body.read)
      @expectations << (expectation = Expectation.new(query: json["query"], response: json["response"]))

      [201, {"Content-Type" => "application/json"}, [{token: expectation.token}.to_json]]
    end

    def setup_strategy_request?(request)
      request.path_info =~ %r{^/api/strategy} &&
        request.request_method == "POST" &&
        request.content_type == "application/json"
    end

    def setup_strategy(request)
      json = JSON.parse(request.body.read)

      strategy_name = json["strategy"]

      @strategy = COMPARE_STRATEGIES.fetch(strategy_name) do
        response = [400, {}, ["strategy=#{strategy_name} does not exists."]]
        return response
      end

      [201, {"Content-Type" => "application/json"}, [{strategy: strategy_name}.to_json]]
    end

    def shift_expectation(request)
      if @expectations.empty?
        response = [412, {}, ["no expectation set."]]
        return response
      end

      expectation = @strategy.call(@expectations)
      serialized_request = RequestSerializer.call(request)
      if expectation.matches?(serialized_request)
        response = [expectation.response["status"], expectation.response["headers"], [expectation.response["body"]]]
        return response
      end

      [422, {}, ["expectation=#{expectation.token} did not match."]]
    end
  end
end
