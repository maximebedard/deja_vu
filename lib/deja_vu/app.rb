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
      elsif clear_request?(request)
        clear_expectations(request)
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
      handle_json(code: 200, body: @expectations)
    end

    def push_expectation?(request)
      request.path_info =~ %r{^/api/expectations} &&
        request.request_method == "POST" &&
        request.content_type == "application/json"
    end

    def clear_request?(request)
      request.path_info =~ %r{^/api/expectations/clear} &&
        request.request_method == "POST" &&
        request.content_type == "application/json"
    end

    def push_expectation(request)
      json = JSON.parse(request.body.read)
      query = json.fetch("query") { return handle_err(code: 400, body: "query not found") }
      response = json.fetch("response") { return handle_err(code: 400, body: "response not found") }

      expectation = Expectation.new(
        query: query,
        response: response,
        token: SecureRandom.hex,
      )

      @expectations << expectation

      handle_json(code: 201, body: {token: expectation.token})
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
        return handle_err(code: 400, body: "strategy=#{strategy_name} does not exists.")
      end

      handle_json(code: 200, body: {strategy: strategy_name})
    end

    def shift_expectation(request)
      if @expectations.empty?
        return handle_err(code: 412, body: "no expectation set.")
      end

      expectation = @strategy.call(@expectations)
      serialized_request = RequestSerializer.new(request).to_h
      if expectation.matches?(serialized_request)
        response = [expectation.response["status"], expectation.response["headers"], [expectation.response["body"]]]
        return response
      end

      handle_err(code: 422, body: "expectation=#{expectation.token} did not match.")
    end

    def clear_expectations(request)
      @expectations.clear
      handle_json(code: 200, body: {})
    end

    def handle_err(code:, body:)
      [code, {}, [body]]
    end

    def handle_json(code:, body:)
      [code, {"Content-Type" => "application/json"}, [body.to_json]]
    end
  end
end
