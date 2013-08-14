module FastbillAutomatic
  class Customer
    PARSED_ATTRIBUTES = %w(customer_id customer_number
      salutation first_name last_name organization
      address zipcode city country_code phone email
      days_for_payment payment_type currency_code customer_type
      bank_name bank_account_number bank_code bank_account_owner vat_id
      show_payment_notice comment newsletter_optin
      created lastupdate customer_ext_uid
    )

    def self.parse data
      customer = self.new()

      PARSED_ATTRIBUTES.each do |attribute|
        customer.attributes[attribute.downcase] = data.fetch(attribute.upcase, '')
      end

      return customer
    end

    # returns an Enumerable containing Customer objects
    def self.all filter = {}, client = FastbillAutomatic.client
      response = client.execute_request('customer.get', { filter: filter })

      results = []
      if response.success?
        results = response.fetch('customers').map { |data| Customer.parse(data) }
      else
        # TODO handle error case
        p response.errors
      end
      return results
    end

    # returns an Customer or UnknownCustomer if id is unknown
    def self.find_by_id id, client = FastbillAutomatic.client
      response = client.execute_request('customer.get', { filter: { customer_id: id } })

      if response.success? && (customers_data = response.fetch('customers')).length > 0
        self.parse(customers_data[0])
      else
        return UnknownCustomer.new
      end
    end

    attr_accessor :client
    attr_accessor :attributes

    def initialize client = FastbillAutomatic.client
      @client = client
      @attributes = Hash.new
    end

    def create
      # customer.create
    end

    def update
      # customer.update
    end

    def destroy
      # customer.delete
    end
  end

  class UnknownCustomer < Customer
    # TODO noop if method is called
  end
end

__END__

not mapped as of 2013-08-14 (rra):
"ADDRESS_2"
"CHANGEDATA_URL"
"DASHBOARD_URL"