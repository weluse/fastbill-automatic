require 'test_helper'

class CustomerTest < Minitest::Test
  attr_accessor :client
  def setup
    @client = ::FastbillAutomatic.client = ::FastbillAutomatic::Client.new("max@mustermann.de", "nopass123")
  end
  def teardown
    ::FastbillAutomatic.client = nil
  end

  def test_all_returns_enumberable_with_customers
    response = Typhoeus::Response.new(code: 200, body: IO.read('test/fixtures/customer_get_without_filter.json'))
    Typhoeus.stub(/automatic.fastbill.com/).and_return(response)

    customers = ::FastbillAutomatic::Customer.all
    assert customers.length == 1

    customer = customers.first
    assert_equal "297343", customer.customer_id
  end

  def test_all_transfers_filter_properly
    #
  end

  def test_find_by_id_returns_customer_if_known
    #
  end

  def test_find_by_id_returns_unknown_customer_if_unknown
    #
  end
end