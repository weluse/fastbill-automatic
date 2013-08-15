require 'test_helper'

class CustomerTest < Minitest::Test
  include ::FastbillAutomatic::Resources
  attr_accessor :client
  def setup
    @client = ::FastbillAutomatic.client = ::FastbillAutomatic::Client.new("max@mustermann.de", "nopass123")
  end
  def teardown
    ::FastbillAutomatic.client = nil
  end

  def test_save_invokes_create_for_new_instances
    customer = Customer.new()
    customer.expects(:create).returns(true)
    customer.save()
  end

  def test_save_invokes_update_for_persisted_instances
    customer = Customer.new({ 'CUSTOMER_ID' => 42 })
    assert_equal 42, customer.customer_id
    customer.expects(:update).returns(true)
    customer.save()
  end

  def test_create_assigns_customer_id_upon_success
    response = Typhoeus::Response.new(code: 200, body: IO.read('test/fixtures/customer_create_success.json'))
    Typhoeus.stub(/automatic.fastbill.com/).and_return(response)

    customer = Customer.new({
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

    customer = Customer.new({
      'CUSTOMER_NUMBER' => '2'
    })
    refute customer.create()
    refute customer.errors.empty?
  end

  def test_update_returns_true_upon_success
    response = Typhoeus::Response.new(code: 200, body: IO.read('test/fixtures/customer_update_success.json'))
    Typhoeus.stub(/automatic.fastbill.com/).and_return(response)

    customer = Customer.new({
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

    customer = Customer.new({
      'CUSTOMER_NUMBER' => '42'
    })
    refute customer.update()
    refute customer.errors.empty?
  end

  def test_destroy_returns_true_upon_success
    response = Typhoeus::Response.new(code: 200, body: IO.read('test/fixtures/customer_delete_success.json'))
    Typhoeus.stub(/automatic.fastbill.com/).and_return(response)

    customer = Customer.new({
      'CUSTOMER_ID' => '42'
    })
    assert customer.destroy()
    assert customer.errors.empty?
  end

  def test_destroy_returns_false_upon_failure_and_sets_errors
    response = Typhoeus::Response.new(code: 200, body: IO.read('test/fixtures/customer_delete_error.json'))
    Typhoeus.stub(/automatic.fastbill.com/).and_return(response)

    customer = Customer.new({
      'CUSTOMER_NUMBER' => '42'
    })
    refute customer.destroy()
    refute customer.errors.empty?
  end

  def test_parses_correctly
    response = Typhoeus::Response.new(code: 200, body: IO.read('test/fixtures/customer_get_without_filter.json'))
    Typhoeus.stub(/automatic.fastbill.com/).and_return(response)

    customers = Customer.all
    assert customers.length == 1

    customer = customers.first
    assert_equal 297343, customer.customer_id
    assert_equal "1", customer.customer_number
    assert_equal 14, customer.days_for_payment
    assert_equal DateTime.parse("2013-08-05 18:15:10"), customer.created
    assert_equal PaymentTypes::UEBERWEISUNG, customer.payment_type
    assert_equal "Deutsche Bank", customer.bank_name
    assert_equal "222222", customer.bank_account_number
    assert_equal "21212121", customer.bank_code
    assert_equal "Oliver Welge", customer.bank_account_owner
    refute customer.show_payment_notice
    assert_equal CustomerTypes::BUSINESS, customer.customer_type
    assert customer.newsletter_optin
    assert_equal "Test Customer", customer.organization
    assert_equal "mr", customer.salutation
    assert_equal "Oliver", customer.first_name
    assert_equal "Welge", customer.last_name
    assert_equal "Teststrasse 20", customer.address
    assert_equal "12345", customer.zipcode
    assert_equal "Hamburg", customer.city
    assert_equal "DE", customer.country_code
    assert_equal "01 - 2345", customer.phone
    assert_equal "owelge@weluse.de", customer.email
    assert_equal "", customer.vat_id
    assert_equal "EUR", customer.currency_code
    assert_equal DateTime.parse("2013-08-05 18:41:34"), customer.lastupdate
  end

  def test_all_uses_client_from_arguments
    response = ::FastbillAutomatic::Response.new(false, {})

    client = stub('FastbillAutomatic::Client')
    client.expects(:execute_request).returns(response)

    Customer.all({}, client)
  end

  def test_find_by_id_returns_existing_customer_if_known
    response = Typhoeus::Response.new(code: 200, body: IO.read('test/fixtures/customer_get_without_filter.json'))
    Typhoeus.stub(/automatic.fastbill.com/).and_return(response)

    customer = Customer.find_by_id("297343")
    assert customer != nil
    assert_equal 297343, customer.customer_id
  end

  def test_find_by_id_returns_unknown_customer_if_unknown
    response = Typhoeus::Response.new(code: 200, body: IO.read('test/fixtures/customer_get_with_empty_response.json'))
    Typhoeus.stub(/automatic.fastbill.com/).and_return(response)

    customer = Customer.find_by_id("2973432")
    assert customer != nil
    assert customer.is_a?(UnknownCustomer)
  end

  def test_find_by_id_uses_client_from_arguments
    response = ::FastbillAutomatic::Response.new(false, {})

    client = stub('FastbillAutomatic::Client')
    client.expects(:execute_request).returns(response)

    Customer.find_by_id('42', client)
  end
end