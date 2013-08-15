require 'test_helper'

class InvoiceTest < Minitest::Test
  attr_accessor :client
  def setup
    @client = ::FastbillAutomatic.client = ::FastbillAutomatic::Client.new("max@mustermann.de", "nopass123")
  end
  def teardown
    ::FastbillAutomatic.client = nil
  end

  include ::FastbillAutomatic::Resources

  def test_parses_correctly
    response = Typhoeus::Response.new(code: 200, body: IO.read('test/fixtures/invoice_get_without_filters.json'))
    Typhoeus.stub(/automatic.fastbill.com/).and_return(response)

    invoices = Invoice.all()

    refute invoices.empty?

    invoice = invoices.first
    assert_equal 366712, invoice.invoice_id
    assert_equal 297343, invoice.customer_id
    assert_equal "1", invoice.invoice_number

    assert_equal InvoiceTypes::OUTGOING, invoice.type
    assert_equal "ueberweisung", invoice.payment_type
    assert_equal "", invoice.comment

    assert_equal "mr", invoice.salutation
    assert_equal "Oliver", invoice.first_name
    assert_equal "Welge", invoice.last_name
    assert_equal "Teststrasse 20", invoice.address
    assert_equal "Test Customer", invoice.organization
    assert_equal "12345", invoice.zipcode
    assert_equal "Hamburg", invoice.city

    assert_equal "Deutsche Bank", invoice.bank_name
    assert_equal "22122", invoice.bank_account_number
    assert_equal "21212", invoice.bank_code
    assert_equal "Oliver Welge", invoice.bank_account_owner

    assert_equal "DE", invoice.country_code

    assert_equal 1, invoice.vat_items.size
    vat_item = invoice.vat_items.first

    assert_equal 19.00, vat_item.vat_percent
    assert_equal 22.00, vat_item.complete_net
    assert_equal 42.00, vat_item.vat_value

    assert_equal 2, invoice.items.size
    item = invoice.items.last

    assert_equal 795573, item.invoice_item_id
    assert_equal "1", item.article_number
    assert_equal "Schaufensterpaket Gratis", item.description
    assert_equal 1.00, item.quantity
    assert_equal 0.00, item.unit_price
    assert_equal 19.00, item.vat_percent
    assert_equal 0.00, item.vat_value
    assert_equal 0.00, item.complete_net
    assert_equal 0.00, item.complete_gross
    assert_equal 2, item.sort_order

  end
end