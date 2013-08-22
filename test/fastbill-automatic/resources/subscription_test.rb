require 'test_helper'

class SubscriptionTest < Minitest::Test
  include ::FastbillAutomatic::Resources

  attr_accessor :client

  def setup
    @client = ::FastbillAutomatic.client = ::FastbillAutomatic::Client.new("max@mustermann.de", "nopass123")
  end

  def teardown
    ::FastbillAutomatic.client = nil
  end

  def test_parses_correctly
    response = Typhoeus::Response.new(code: 200, body: IO.read('test/fixtures/subscription_get_success.json'))
    Typhoeus.stub(/automatic.fastbill.com/).and_return(response)

    subscriptions = Subscription.all()

    refute subscriptions.empty?
    assert_equal 2, subscriptions.size

    subscription = subscriptions.first
    assert_equal 967, subscription.id
    assert_equal 297683, subscription.customer_id
    assert_equal DateTime.parse("2013-08-15 13:36:49"), subscription.start
    assert_equal DateTime.parse("2013-09-15 13:36:49"), subscription.next_event
    assert_equal DateTime.parse("2013-11-15 13:36:49"), subscription.cancellation_date
    assert subscription.cancelled?
    assert_equal 1, subscription.article_number
    assert_equal "42", subscription.subscription_ext_uid
    assert_equal DateTime.parse("2013-08-15 13:36:49"), subscription.last_event
  end
end