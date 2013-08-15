module FastbillAutomatic
  module Resources
    # CustomerTypes supported by Fastbill
    #
    # Customer#customer_type contains a String which can be compared
    # to these enums.
    module CustomerTypes
      # business customer
      BUSINESS = "business"
      # consumer customer
      CONSUMER = "consumer"
    end

    # PaymentTypes supported by Fastbill.
    module PaymentTypes
      # using cashless money transfer
      UEBERWEISUNG = 1

      # using debit
      LASTSCHRIFT = 2

      # using cash
      BAR = 3

      # using paypal
      PAYPAL = 4

      # using payment in advance
      VORKASSE = 5

      # using credit card
      KREDITKARTE = 6
    end

    # The Customer class wraps basic interactions for
    # customer.get|update|delete service calls.
    #
    # When creating instances of Customer one can pass
    # all values specified in PARSED_ATTRIBUTES along and the attributes
    # will be set accordingly.
    #
    # E.g.
    # ::Customer.new({ customer_id: 42 })
    class Customer < Base
      attribute :customer_id, Integer
      attribute :customer_number, String

      attribute :salutation, String
      attribute :first_name, String
      attribute :last_name, String
      attribute :organization, String
      attribute :address, String
      attribute :zipcode, String
      attribute :city, String
      attribute :country_code, String
      attribute :phone, String
      attribute :email, String

      attribute :days_for_payment, Integer
      attribute :payment_type, Integer
      attribute :currency_code, String
      attribute :customer_type, String

      attribute :bank_name, String
      attribute :bank_account_number, String
      attribute :bank_account_owner, String
      attribute :bank_code, String
      attribute :vat_id, String

      attribute :show_payment_notice, Boolean
      attribute :comment, String
      attribute :newsletter_optin, Boolean

      attribute :created, DateTime
      attribute :lastupdate, DateTime
      attribute :customer_ext_uid, String

      # Returns an Enumerable containing Customer objects.
      #
      # filter supports the following keys:
      # * customer_id      same as .find_by_id
      # * customer_number  search customer by exact customer_number
      # * country_code     search customers by country
      # * city             search customers by city
      # * term             search customers by term (only ORGANIZATION, FIRST_NAME, LAST_NAME, ADDRESS, ADDRESS_2, ZIPCODE, EMAIL)
      def self.all filter = {}, client = FastbillAutomatic.client
        response = client.execute_request('customer.get', { filter: filter })

        results = []
        if response.success?
          results = response.fetch('customers').map { |data| self.new(data, client) }
        else
          # TODO handle error case
          p response.errors
        end
        return results
      end

      # Returns an Customer if the id is known.
      # Otherwise returns an instance of UnknownCustomer
      def self.find_by_id id, client = FastbillAutomatic.client
        response = client.execute_request('customer.get', { filter: { customer_id: id } })

        if response.success? && (customers_data = response.fetch('customers')).length > 0
          self.new(customers_data[0], client)
        else
          return UnknownCustomer.new
        end
      end

      # Decides if a Customer is persisted by looking at its #customer_id
      def new?
        return self.customer_id.to_s == ''
      end

      # Executes customer.create. If the response succeeds the #customer_id is set and true is returned.
      #
      # If the request fails #errors is set.
      def create
        response = client.execute_request('customer.create', {
          data: attributes
        })

        if response.success? && response.fetch('status') == 'success'
          self.customer_id = response.fetch('customer_id')
          @errors = []
          return true
        end

        @errors = response.errors
        return false
      end

      # Executes customer.update. Returns true if the response succeeded.
      #
      # If the request fails #errors is set.
      def update
        response = client.execute_request('customer.update', {
          data: attributes
        })

        if response.success? && response.fetch('status') == 'success'
          @errors = []
          return true
        end

        @errors = response.errors
        return false
      end

      # Executes customer.delete. Returns true if the response succeeded.
      #
      # If the request fails #error is set
      def destroy
        response = client.execute_request('customer.delete', {
          data: {
            customer_id: self.customer_id
          }
        })

        if response.success? && response.fetch('status') == 'success'
          @errors = []
          return true
        end

        @errors = response.errors
        return false
      end
    end

    # When calls to Customer.find_by_id return no results
    # an instance of UnknownCustomer is returned instead.
    #
    # UnknownCustomer acts like a regular Customer
    # except that you can not #create, #update or #destroy it.
    class UnknownCustomer < Customer
      def create; end
      def update; end
      def destroy; end
    end
  end
end

__END__

not mapped as of 2013-08-14 (rra):
"ADDRESS_2"
"CHANGEDATA_URL"
"DASHBOARD_URL"