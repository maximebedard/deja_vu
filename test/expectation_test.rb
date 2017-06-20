require "test_helper"

module DejaVu
  class ExpectationTest < Minitest::Test
    def test_initialize_coerce_query_to_h
      assert_raises(TypeError) do
        Expectation.new(query: "patate", response: {})
      end
    end

    def test_initialize_coerce_response_to_h
      assert_raises(TypeError) do
        Expectation.new(query: {}, response: "patate")
      end
    end

    def test_exact_matches?
      query = {a: "a", b: 1, c: nil, d: [1, "2", nil]}
      assert(Expectation.new(query: query, response: {}).matches?(query))
    end

    def test_intersect_matches?
      query = {a: "a"}
      assert(Expectation.new(query: query, response: {}).matches?(a: "a", b: 1, c: nil))
    end

    def test_nested_exact_matches?
      query = {a: "a", b: {c: "c", d: 1, e: nil, f: [1, "2", nil]}}
      assert(Expectation.new(query: query, response: {}).matches?(query))
    end

    def test_nested_intersect_matches?
      query = {a: "a", b: {c: "c", d: 1, e: nil, f: [1, "2", nil]}}
      assert(Expectation.new(query: query, response: {}).matches?(a: "a", b: {c: "c", d: 1}))
    end

    def test_regex_matches?
      query = {a: /^max/}
      assert(Expectation.new(query: query, response: {}).matches?(a: "maximum"))
    end
  end
end
