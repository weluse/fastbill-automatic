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
    #
    # === Examples
    #   include ::FastbillAutomatic::Resources
    #
    #   # create a new invoice
    #   invoice = Invoices.new({
    #     customer_id: customer.customer_id,
    #     currency_code: 'EUR',
    #     eu_delivery: true,
    #     items: [
    #       {
    #         description: 'Example',
    #         unit_price: 200.0,
    #         vat_percent: 19.0,
    #         quantity: 2
    #       }
    #     ]
    #   })
    #   invoice.save # => true
    #
    #   # change the price of an item
    #   first_item = invoice.items.first
    #   first_item.quantity = 4
    #   first_item.unit_price = 50
    #
    #   invoice.save # => true
    #
    #   # remove all items
    #   invoice.items = []
    #   invoice.save # => true
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
      attribute :eu_delivery, Boolean

      attribute :vat_items, Array[VatItem]
      attribute :items, Array[InvoiceItem]

      # set to true to replace items
      attribute :delete_existing_items, Boolean, default: false

      alias_method :id, :invoice_id
      alias_method :id=, :invoice_id=

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
        results = self.all({ invoice_id: id }, client)

        return results.first || UnknownInvoice.new
      end

      # Executes invoice.create
      def create
        response = client.execute_request('invoice.create', {
          data: transform_attributes(self.attributes, %i(vat_items delete_existing_items))
        })

        if response.success? && response.fetch('status') == 'success'
          self.invoice_id = response.fetch('invoice_id')
          @errors = []
          return true
        end

        @errors = response.errors
        return false
      end

      # Executes invoice.update
      def update
        self.delete_existing_items = true
        response = client.execute_request('invoice.update', {
          data: transform_attributes
        })

        if response.success? && response.fetch('status') == 'success'
          @errors = []
          return true
        end

        @errors = response.errors
        return false
      end

      # Executes invoice.delete
      #
      # Only works if your invoice is still a draft (you did not call #complete yet).
      def destroy
        response = client.execute_request('invoice.delete', {
          data: {
            invoice_id: self.invoice_id
          }
        })

        if response.success? && response.fetch('status') == 'success'
          @errors = []
          return true
        end

        @errors = response.errors
        return false
      end

      # Transforms your draft into a ready-to-bill real invoice.
      def complete
        response = client.execute_request('invoice.complete', {
          data: {
            invoice_id: self.invoice_id
          }
        })

        if response.success? && response.fetch('status') == 'success'
          @errors = []
          return true
        end

        @errors = response.errors
        return false
      end

      # Cancels the invoice.
      def cancel
        response = client.execute_request('invoice.cancel', {
          data: {
            invoice_id: self.invoice_id
          }
        })

        if response.success? && response.fetch('status') == 'success'
          @errors = []
          return true
        end

        @errors = response.errors
        return false
      end

      # Notifies the recipient of an invoice using email. The Email is send by FastbillAutomatic.
      def send_by_email subject, message, recipient
        response = client.execute_request('invoice.sendbyemail', {
          data: {
            invoice_id: self.invoice_id,
            recipient: recipient,
            subject: subject,
            message: message
          }
        })

        if response.success? && response.fetch('status') == 'success'
          @errors = []
          return true
        end

        @errors = response.errors
        return false
      end

      # Decides if a Invoice is persisted by looking at its #invoice_id
      def new?
        return self.invoice_id.to_s == ''
      end

      # Transforms attributes so they can be properly submitted to Fastbill
      def transform_attributes attrs = self.attributes, exclusion_list = %i(vat_items)
        hash = Hash.new
        attrs.keys
          .reject { |key| exclusion_list.include?(key) }
          .each do |key|
            value = attrs[key]
            if value.is_a?(Array)
              hash[key] = value.map { |item| transform_attributes(item.attributes) }
            else
              hash[key] = value
            end

          end
        return hash
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