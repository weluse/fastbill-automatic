module FastbillAutomatic

  # The Customer class wraps basic interactions for
  # customer.get|update|delete service calls.
  #
  # When creating instances of Customer one can pass
  # all values specified in PARSED_ATTRIBUTES along and the attributes
  # will be set accordingly.
  #
  # E.g.
  # ::Customer.new({ customer_id: 42 })
  class Customer
    # Only attributes specified in this array are parsed from FastbillAutomatic responses.
    #
    # Note that the current setup only allows for flat attribute parsing, nesting is not supported.
    PARSED_ATTRIBUTES = %w(customer_id customer_number
      salutation first_name last_name organization
      address zipcode city country_code phone email
      days_for_payment payment_type currency_code customer_type
      bank_name bank_account_number bank_code bank_account_owner vat_id
      show_payment_notice comment newsletter_optin
      created lastupdate customer_ext_uid
    )

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

    # must be an instance of Client or compatible.
    #
    # The client is used to build and execute queries against FastbillAutomatic
    attr_reader :client

    # contains all attributes read- and written from and to the FastbillAutomatic API
    #
    # It is currently not possible to pass along additional attributes.
    attr_reader :attributes

    # are set if an request to the FastbillAutomatic API failed. Most
    # of the time it will contain an Array of error messages.
    attr_reader :errors

    # Creates a new instance of Customer using passed attrs to initialize the
    # instance attributes
    def initialize attrs = Hash.new, client = FastbillAutomatic.client
      @client = client
      parse_attributes attrs, true
      @errors = []
    end

    # Invokes either #create or #update, depending on the current state of the instance
    def save
      if new?
        return create()
      else
        return update()
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

    # To allow easy access to our attributes overwrite method_missing and
    # as a good citizen also overwrite respond_to?
    def respond_to? method, *args
      if known_attribute?(method) || known_attribute_setter?(method)
        return true
      else
        return super
      end
    end

    def method_missing method, *args
      if known_attribute?(method)
        return @attributes[clean_method_name(method)]
      elsif (_attr = known_attribute_setter?(method))
        @attributes[_attr] = args[0]
      else
        return super
      end
    end

    protected
    def known_attribute? method
      return PARSED_ATTRIBUTES.include?(clean_method_name(method))
    end
    def known_attribute_setter? method
      if clean_method_name(method) =~ /\A(\w+)=\z/
        return $1 if PARSED_ATTRIBUTES.include?($1)
        return false
      end
      return false
    end
    def clean_method_name method
      return method.to_s.downcase
    end

    def parse_attributes attrs, case_insensitive = false
      @attributes = Hash.new
      if case_insensitive
        cleaned_attrs = Hash.new
        attrs.each do |key, value|
          cleaned_attrs[key.to_s.upcase] = value
        end
        attrs = cleaned_attrs
      end

      PARSED_ATTRIBUTES.each do |attribute|
        @attributes[clean_method_name(attribute)] = attrs.fetch(clean_method_name(attribute).upcase, '')
      end
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

__END__

not mapped as of 2013-08-14 (rra):
"ADDRESS_2"
"CHANGEDATA_URL"
"DASHBOARD_URL"