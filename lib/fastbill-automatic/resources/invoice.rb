module FastbillAutomatic
  module Resources
    # VatItem entry. Occurs in Invoice#vat_items
    class VatItem
      include Virtus

      attribute :vat_percent, Float
      attribute :complete_net, BigDecimal
      attribute :vat_value, BigDecimal
    end

    # InvoiceItem entry. Occurs in Invoice#items
    class InvoiceItem
      include Virtus

      attribute :invoice_item_id, Integer
      attribute :article_number, String
      attribute :description, String
      attribute :quantity, Float
      attribute :unit_price, BigDecimal
      attribute :vat_percent, Float
      attribute :vat_value, BigDecimal
      attribute :complete_net, BigDecimal
      attribute :complete_gross, BigDecimal
      attribute :sort_order, Integer
    end

    # Different types of invoice Fastbill supports
    module InvoiceTypes
      # an invoice which must be paid
      OUTGOING = "outgoing"
      # a draft the customer has not yet received
      DRAFT = "draft"
      # a credit the customer was given (Gutschrift)
      CREDIT = "credit"
    end

    # The Invoice class wraps basic interactions for invoice.get|create|update|delete service calls.
    class Invoice < Base
      attribute :invoice_id, Integer
      attribute :invoice_number, String
      attribute :customer_id, Integer
      attribute :customer_costcenter_id, Integer

      attribute :type, String
      attribute :comment, String

      attribute :salutation, String
      attribute :first_name, String
      attribute :last_name, String
      attribute :organization, String
      attribute :address, String
      attribute :zipcode, String
      attribute :city, String
      attribute :country_code, String

      attribute :payment_type, String
      attribute :bank_name, String
      attribute :bank_account_number, String
      attribute :bank_code, String
      attribute :bank_account_owner, String

      attribute :country_code, String
      attribute :vat_id, String
      attribute :currency_code, String
      attribute :paid_date, DateTime
      attribute :invoice_date, DateTime
      attribute :due_date, DateTime
      attribute :delivery_date, DateTime
      attribute :is_canceled, Boolean

      attribute :template_id, Integer

      attribute :introtext, String
      attribute :cash_discount_percent, Float
      attribute :cash_discount_days, Integer
      attribute :sub_total, BigDecimal
      attribute :vat_total, BigDecimal
      attribute :total, BigDecimal

      attribute :vat_items, Array[VatItem]
      attribute :items, Array[InvoiceItem]

      # Returns an Enumerable containing Invoice objects.
      #
      # filter supports the following keys:
      # * invoice_id      same as .find_by_id
      # * invoice_number  search for a specific invoice_number
      # * customer_id     search for Invoices of a specific Customer
      # * month           search for Invoices in a specific month
      # * year            search for Invoices in a specific year
      # * state           search for Invoices with a specific state (paid, unpaid, overdue)
      # * type            search for Invoices in a specific type (outgoing, draft, credit)
      def self.all filter = {}, client = FastbillAutomatic.client
        response = client.execute_request('invoice.get', { filter: filter })

        results = []
        if response.success?
          results = response.fetch('invoices').map { |data| self.new(data, client) }
        else
          # TODO handle error case
          p response.errors
        end
        return results
      end

      # Returns a single Invoice object
      #
      # Same as Invoice.filter({ invoice_id: id }) except that
      # an instance of UnknownInvoice can be returned
      def self.find_by_id id, client = FastbillAutomatic.client
        response = client.execute_request('invoice.get', { filter: { invoice_id: id } })

        if response.success? && (invoices_data = response.fetch('invoices')).length > 0
          self.new(invoices_data[0], client)
        else
          return UnknownInvoice.new
        end
      end

      # Decides if a Customer is persisted by looking at its #customer_id
      def new?
        return self.invoice_id.to_s == ''
      end
    end

    # An Invoice that Fastbill does not known about.
    #
    # You'll see this if you call .find_by_id with an unknown id.
    class UnknownInvoice < Invoice
      def create; end
      def update; end
      def destroy; end
    end
  end
end