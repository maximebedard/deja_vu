module DejaVu
  class Expectation
    attr_reader(
      :entries,
      :token,
      :response,
    )

    def initialize(entries:, response:)
      @entries = entries
      @response = response
      @token = SecureRandom.hex
    end

    def matches?(request)
      true
    end
  end
end
