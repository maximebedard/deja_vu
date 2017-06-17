# RemoteWebMock

Testing external services within browser tests is hard. This is
an attempt toward making this a little simpler by setting up
expectations -- exactly like webmock --, but on a remote proxy.

Here's an example:

```rb
class CheckoutFormBrowserTest < BrowserTest
  test "pay with magic provider " do
    add_video_game_to_cart
    visit "/cart"

    click_pay_with_magic # redirects to magic.example.com/start

    assert_on_step "Customer information"
    assert_magic_provider_customer_information_widget # makes a request to magic.example.com/saved_accounts

    # ...
  end
end
```

A WebMock user would be tempted to do the following:

```rb
test "pay with magic provider " do
  stub_request(:get, "magic.example.com/start")
    .to_return(body: "success")

  stub_request(:get, "magic.example.com/saved_accounts")
    .to_return(body: "even more success")

  # same as before...
end
```

However this has no effects since the request is executed by the browser, not the server's code.

## Installation

```sh
$ gem install remote_web_mock
```

## Usage

Going back to the original example, a similar API is provided
but instead of stubbing the request by collecting the request
to the network adapter currently being used by the server, we
tell a proxy to expect a given request and return the response
we want if that request is really expected.

```rb
RemoteWebMock::TestHelper.proxy_uri = "localhost:9292"
RemoteWebMock::TestHelper.interactions_dir = "./"

class CheckoutFormBrowserTest < BrowserTest
  test "pay with magic provider " do
    expects_proxy(path: "/start").to_return(body: "success")
    expects_proxy(path: "/saved_accounts").to_return(body: "even more success")

    add_video_game_to_cart
    visit "/cart"

    click_pay_with_magic # redirects to magic.example.com/start

    assert_on_step "Customer information"
    assert_magic_provider_customer_information_widget # makes a request to magic.example.com/saved_accounts

    # ...
  end
end
```

The test will now pass, and everyone will be able to sleep a little better at night.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/maximebedard/remote_web_mock.
