module FastbillAutomatic
  class Customers
    attr_accessor :client
    def initialize client
      @client = client
    end

    # returns an Enumerable containing Customer objects
    def all filter = {}
      body = client.build_body({ service: 'customer.get', filter: filter })
      request = client.build_request({
        body: JSON.dump(body)
      })
      response = request.run

      results = []
      if response.success?
        # TODO parse response
      end
      return results
    end

    # returns an Customer or UnknownCustomer if id is unknown
    def find_by_id id
      # customer.get with id
    end
  end
end