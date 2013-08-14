module FastbillAutomatic
  # The Invoice class wraps basic interactions for invoice.get|create|update|delete service calls.
  class Invoice

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
    def self.all filters = {}, client = FastbillAutomatic.client
    end
  end
end