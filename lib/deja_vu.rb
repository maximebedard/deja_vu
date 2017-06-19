require "json"
require "securerandom"
require "rack/request"
require "deja_vu/expectation"
require "deja_vu/remote_expectation"
require "deja_vu/version"

module DejaVu
  class App
    attr_accessor(:expectations)

    def initialize
      @expectations = []
    end

    def call(env)
      request = Rack::Request.new(env)

      if push_expectation?(request)
        push_expectation(request)
      else
        shift_expectation(request)
      end
    end

    private

    def push_expectation?(request)
      request.path_info =~ %r{^/api/expectations} &&
        request.request_method == "POST" &&
        request.content_type == "application/json"
    end

    def push_expectation(request)
      json = JSON.parse(request.body.read)
      @expectations << (expectation = Expectation.new(entries: json["entries"], response: json["response"]))

      [201, {"Content-Type" => "application/json"}, [{token: expectation.token}.to_json]]
    end

    def shift_expectation(request)
      if @expectations.empty?
        response = [412, {}, ["no expectation set."]]
        return response
      end

      expectation = @expectations.shift
      if expectation.matches?(request)
        response = [expectation.response["status"], expectation.response["headers"], [expectation.response["body"]]]
        return response
      end

      [422, {}, ["expectation(#{expectation.token}) did not match."]]
    end
  end
end
