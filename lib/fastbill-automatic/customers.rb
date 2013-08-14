module FastbillAutomatic
  class Customers
    attr_accessor :client
    def initialize client = FastbillAutomatic.client
      @client = client
    end

    # returns an Enumerable containing Customer objects
    def all filter = {}
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
    def find_by_id id
      # customer.get with id
    end
  end
end