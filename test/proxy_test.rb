require "test_helper"

module DejaVu
  class ProxyTest < Minitest::Test
    def setup
      @proxy = Proxy.new
    end

    def test_expects_proxy
      remote_expectation = @proxy.expects(path: "/patate")

      assert_respond_to(remote_expectation, :to_return)
      assert_respond_to(remote_expectation, :to_return_recorded_interaction)
    end

    def test_expects_proxy_to_return
      stub_request(:post, "#{Proxy::DEFAULT_URI}/api/expectations")
        .to_return(body: "patate")

      @proxy.expects(path: "/patate")
        .to_return(body: "patate")
    end

    def test_expects_proxy_to_return_with_https_custom_uri
      uri = "https://patate.poil.com"
      @proxy = Proxy.new(uri: uri)

      stub_request(:post, "#{uri}/api/expectations")
        .to_return(body: "patate")

      @proxy.expects(path: "/patate")
        .to_return(body: "patate")
    end

    def test_expects_proxy_to_return_recorded_interaction
      stub_request(:post, "#{Proxy::DEFAULT_URI}/api/expectations")
        .to_return(body: {"song" => "Dirty Work"}.to_json)

      @proxy.expects(path: "/patate")
        .to_return_recorded_interaction("./test/fixtures/recorded_01")
    end

    def test_expects_proxy_to_return_recorded_interaction_with_custom_dir
      interactions_dir = "./test/fixtures"
      @proxy = Proxy.new(interactions_dir: interactions_dir)

      stub_request(:post, "#{Proxy::DEFAULT_URI}/api/expectations")
        .to_return(body: {"song" => "Dirty Work"}.to_json)

      @proxy.expects(path: "/patate")
        .to_return_recorded_interaction("recorded_01")
    end

    private

    def custom_proxy_uri(uri)
      old = Proxy.proxy_uri
      Proxy.proxy_uri = uri
      yield
    ensure
      Proxy.proxy_uri = old
    end

    def custom_interactions_dir(dir)
      old = Proxy.interactions_dir
      Proxy.interactions_dir = dir
      yield
    ensure
      Proxy.interactions_dir = old
    end
  end
end
