require "test_helper"

module DejaVu
  class RemoteExpectationTest < Minitest::Test
    include RemoteExpectation

    def test_expects_proxy
      proxy = expects_proxy(path: "/patate")

      assert_respond_to(proxy, :to_return)
      assert_respond_to(proxy, :to_return_recorded_interaction)
    end

    def test_expects_proxy_to_return
      stub_request(:post, "#{RemoteExpectation::DEFAULT_PROXY_URI}/api/expectations")
        .to_return(body: "patate")

      expects_proxy(path: "/patate")
        .to_return(body: "patate")
    end

    def test_expects_proxy_to_return_with_custom_uri
      custom_proxy_uri("http://patate.poil.com") do
        stub_request(:post, "#{RemoteExpectation.proxy_uri}/api/expectations")
          .to_return(body: "patate")

        expects_proxy(path: "/patate")
          .to_return(body: "patate")
      end
    end

    def test_expects_proxy_to_return_with_https_custom_uri
      custom_proxy_uri("https://patate.poil.com") do
        stub_request(:post, "#{RemoteExpectation.proxy_uri}/api/expectations")
          .to_return(body: "patate")

        expects_proxy(path: "/patate")
          .to_return(body: "patate")
      end
    end

    def test_expects_proxy_to_return_recorded_interaction
      stub_request(:post, "#{RemoteExpectation::DEFAULT_PROXY_URI}/api/expectations")
        .to_return(body: {"song" => "Dirty Work"}.to_json)

      expects_proxy(path: "/patate")
        .to_return_recorded_interaction("./test/fixtures/recorded_01")
    end

    def test_expects_proxy_to_return_recorded_interaction_with_custom_dir
      custom_interactions_dir("./test/fixtures") do
        stub_request(:post, "#{RemoteExpectation::DEFAULT_PROXY_URI}/api/expectations")
          .to_return(body: {"song" => "Dirty Work"}.to_json)

        expects_proxy(path: "/patate")
          .to_return_recorded_interaction("recorded_01")
      end
    end

    private

    def custom_proxy_uri(uri)
      old = RemoteExpectation.proxy_uri
      RemoteExpectation.proxy_uri = uri
      yield
    ensure
      RemoteExpectation.proxy_uri = old
    end

    def custom_interactions_dir(dir)
      old = RemoteExpectation.interactions_dir
      RemoteExpectation.interactions_dir = dir
      yield
    ensure
      RemoteExpectation.interactions_dir = old
    end
  end
end
