module FastbillAutomatic
  class Customer
    attr_accessor :client
    def initialize client
      @client = client
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