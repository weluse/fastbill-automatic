require 'test_helper'

class CustomerTest < Minitest::Test
  attr_accessor :client
  def setup
    @client = ::FastbillAutomatic.client = ::FastbillAutomatic::Client.new("max@mustermann.de", "nopass123")
  end
  def teardown
    ::FastbillAutomatic.client = nil
  end

  def test_attribute_getter
    customer = ::FastbillAutomatic::Customer.new({
      'CUSTOMER_ID' => 42
    })
    assert customer.respond_to?(:customer_id)
    assert_equal 42, customer.customer_id
  end

  def test_attribute_setter
    customer = ::FastbillAutomatic::Customer.new()
    assert_equal '', customer.customer_id

    assert customer.respond_to?(:customer_id=)
    customer.customer_id = 42
    assert_equal 42, customer.customer_id
  end

  def test_is_new
    customer = ::FastbillAutomatic::Customer.new()
    assert customer.new?

    customer.customer_id = 42
    assert !customer.new?
  end

  def test_save_invokes_create_for_new_instances
    customer = ::FastbillAutomatic::Customer.new()
    customer.expects(:create).returns(true)
    customer.save()
  end

  def test_save_invokes_update_for_persisted_instances
    customer = ::FastbillAutomatic::Customer.new({ 'CUSTOMER_ID' => 42 })
    customer.expects(:update).returns(true)
    customer.save()
  end

  def test_create_assigns_customer_id_upon_success
    response = Typhoeus::Response.new(code: 200, body: IO.read('test/fixtures/customer_create_success.json'))
    Typhoeus.stub(/automatic.fastbill.com/).and_return(response)

    customer = ::FastbillAutomatic::Customer.new({
      'CUSTOMER_NUMBER' => '2',
      'CUSTOMER_TYPE' => 'business',
      'ORGANIZATION' => 'Musterfirma',
      'ZIPCODE' => '12345',
      'CITY' => 'Kiel',
      'COUNTRY_CODE' => 'DE',
      'PAYMENT_TYPE' => '1'
    })
    assert customer.create()

    assert_equal 42, customer.customer_id
    assert customer.errors.empty?
  end

  def test_create_does_nothing_upon_failure
    response = Typhoeus::Response.new(code: 200, body: IO.read('test/fixtures/customer_create_error.json'))
    Typhoeus.stub(/automatic.fastbill.com/).and_return(response)

    customer = ::FastbillAutomatic::Customer.new({
      'CUSTOMER_NUMBER' => '2'
    })
    assert !customer.create()
    assert !customer.errors.empty?
  end

  def test_update_returns_true_upon_success
    response = Typhoeus::Response.new(code: 200, body: IO.read('test/fixtures/customer_update_success.json'))
    Typhoeus.stub(/automatic.fastbill.com/).and_return(response)

    customer = ::FastbillAutomatic::Customer.new({
      'CUSTOMER_ID' => '42',
      'CUSTOMER_TYPE' => 'business',
      'ORGANIZATION' => 'Musterfirma',
      'ZIPCODE' => '12345',
      'CITY' => 'Kiel',
      'COUNTRY_CODE' => 'DE',
      'PAYMENT_TYPE' => '1'
    })
    assert customer.update()
    assert customer.errors.empty?
  end

  def test_update_returns_false_upon_failure_and_sets_errors
    response = Typhoeus::Response.new(code: 200, body: IO.read('test/fixtures/customer_update_error.json'))
    Typhoeus.stub(/automatic.fastbill.com/).and_return(response)

    customer = ::FastbillAutomatic::Customer.new({
      'CUSTOMER_NUMBER' => '42'
    })
    assert !customer.update()
    assert !customer.errors.empty?
  end

  def test_destroy_returns_true_upon_success
    response = Typhoeus::Response.new(code: 200, body: IO.read('test/fixtures/customer_delete_success.json'))
    Typhoeus.stub(/automatic.fastbill.com/).and_return(response)

    customer = ::FastbillAutomatic::Customer.new({
      'CUSTOMER_ID' => '42'
    })
    assert customer.destroy()
    assert customer.errors.empty?
  end

  def test_destroy_returns_false_upon_failure_and_sets_errors
    response = Typhoeus::Response.new(code: 200, body: IO.read('test/fixtures/customer_delete_error.json'))
    Typhoeus.stub(/automatic.fastbill.com/).and_return(response)

    customer = ::FastbillAutomatic::Customer.new({
      'CUSTOMER_NUMBER' => '42'
    })
    assert !customer.destroy()
    assert !customer.errors.empty?
  end

  def test_all_returns_enumberable_with_customers
    response = Typhoeus::Response.new(code: 200, body: IO.read('test/fixtures/customer_get_without_filter.json'))
    Typhoeus.stub(/automatic.fastbill.com/).and_return(response)

    customers = ::FastbillAutomatic::Customer.all
    assert customers.length == 1

    customer = customers.first
    assert_equal "297343", customer.customer_id
  end

  def test_find_by_id_returns_existing_customer_if_known
    response = Typhoeus::Response.new(code: 200, body: IO.read('test/fixtures/customer_get_without_filter.json'))
    Typhoeus.stub(/automatic.fastbill.com/).and_return(response)

    customer = ::FastbillAutomatic::Customer.find_by_id("297343")
    assert customer != nil
    assert_equal "297343", customer.customer_id
  end

  def test_find_by_id_returns_unknown_customer_if_unknown
    response = Typhoeus::Response.new(code: 200, body: IO.read('test/fixtures/customer_get_with_empty_response.json'))
    Typhoeus.stub(/automatic.fastbill.com/).and_return(response)

    customer = ::FastbillAutomatic::Customer.find_by_id("2973432")
    assert customer != nil
    assert customer.is_a?(::FastbillAutomatic::UnknownCustomer)
  end
end