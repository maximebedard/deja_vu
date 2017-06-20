module DejaVu
  class Expectation
    attr_reader(
      :query,
      :token,
      :response,
    )

    def initialize(query:, response:)
      @query = Hash(query)
      @response = Hash(response)
      @token = SecureRandom.hex
    end

    def matches?(actual)
      deep_matches?(actual, query)
    end

    private

    def deep_matches?(a, b)
      (a.keys & b.keys).all? { |k| compare?(a[k], b[k]) }
    end

    def compare?(a, b)
      if [a, b].all? { |v| v.is_a?(Hash) }
        deep_matches?(a, b)
      elsif b.is_a?(Regexp)
        a =~ b
      elsif b.is_a?(String) && b =~ /\(\?.*\:.*\)/
        a =~ Regexp.new(b)
      else
        a == b
      end
    end
  end
end
