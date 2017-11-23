module DejaVu
  class Expectation
    attr_reader(
      :query,
      :response,
      :token,
    )

    def initialize(query:, response:, token:)
      @query = Hash(query)
      @response = Hash(response)
      @token = token
    end

    def matches?(actual)
      deep_matches?(actual, @query)
    end

    private

    def deep_matches?(left, right)
      (left.keys & right.keys).all? { |k| compare?(left[k], right[k]) }
    end

    def compare?(left, right)
      if [left, right].all? { |v| v.is_a?(Hash) }
        deep_matches?(left, right)
      elsif right.is_a?(Regexp)
        left =~ right
      elsif right.is_a?(String) && right =~ /\(\?.*\:.*\)/
        left =~ Regexp.new(right)
      else
        left == right
      end
    end
  end
end
