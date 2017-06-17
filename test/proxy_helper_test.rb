require "test_helper"

module RemoteWebMock
  class ProxyHelperTest < Minitest::Test
    include ProxyHelper

    def test_expects_proxy
      proxy = expects_proxy(path: "/patate")

      assert_respond_to(proxy, :to_return)
      assert_respond_to(proxy, :to_return_recorded_interaction)
    end

    def test_expects_proxy_to_return
      stub_request(:post, "localhost:9292/patate")
        .to_return(body: "patate")

      expects_proxy(path: "/patate")
        .to_return(body: "patate")
    end

    def test_expects_proxy_to_return_with_custom_uri
      custom_proxy_uri("patate.poil.com") do
        stub_request(:post, "#{ProxyHelper.proxy_uri}/patate")
          .to_return(body: "patate")

        expects_proxy(path: "/patate")
          .to_return(body: "patate")
      end
    end

    def test_expects_proxy_to_return_recorded_interaction
    end

    def test_expects_proxy_to_return_recorded_interaction_with_custom_dir
    end

    private

    def custom_proxy_uri(uri)
      old = ProxyHelper.proxy_uri
      ProxyHelper.proxy_uri = uri
      yield
    ensure
      ProxyHelper.proxy_uri = old
    end

    def custom_interactions_dir(dir)
      old = ProxyHelper.interactions_dir
      ProxyHelper.interactions_dir = dir
      yield
    ensure
      ProxyHelper.interactions_dir = old
    end
  end
end
