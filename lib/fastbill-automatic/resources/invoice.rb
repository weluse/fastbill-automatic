module FastbillAutomatic
  module Resources
    # The Invoice class wraps basic interactions for invoice.get|create|update|delete service calls.
    class Invoice < Base

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

      def initialize data, client = FastbillAutomatic.client
      end
    end
  end
end