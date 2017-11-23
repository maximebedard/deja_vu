module DejaVu
  class RequestSerializer
    def initialize(request)
      @request = request
    end

    def to_h
      {
        "path" => @request.env[Rack::PATH_INFO],
        "method" => @request.env[Rack::REQUEST_METHOD].upcase,
        "body" => @request.env[Rack::RACK_INPUT].read,
        "params" => @request.params,
      }
    end
  end
end
