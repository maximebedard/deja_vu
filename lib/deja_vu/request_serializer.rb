module DejaVu
  module RequestSerializer
    def self.call(request)
      {
        "path" => request.env[Rack::PATH_INFO],
        "method" => request.env[Rack::REQUEST_METHOD].upcase,
        "body" => request.env[Rack::RACK_INPUT].read,
        "params" => request.params,
      }
    end
  end
end
