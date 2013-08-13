module FastbillAutomatic
  class Customers
    attr_accessor :client
    def initialize client
      @client = client
    end

    def all
      # customer.get without id
    end

    def find_by_id id
      # customer.get with id
    end
  end
end