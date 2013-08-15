module FastbillAutomatic
  module Resources
    class Subscription < Base
      attribute :subscription_id, Integer
      attribute :customer_id, Integer
      attribute :start, DateTime
      attribute :next_event, DateTime
      attribute :cancellation_date, DateTime
      attribute :status, String
      attribute :article_number, String
      attribute :subscription_ext_uid, String
      attribute :last_event, DateTime

      # Returns an Enumerable containing Subscription objects.
      #
      # filter supports the following keys:
      # * subscription_id      same as .find_by_id
      # * customer_id          returns all subscriptions of a customer
      def self.all filter = {}, client = FastbillAutomatic.client
        response = client.execute_request('subscription.get', { filter: filter })

        results = []
        if response.success?
          results = response.fetch('subscriptions').map { |data| self.new(data, client) }
        else
          # TODO handle error case
          p response.errors
        end
        return results
      end

      # Executes subscription.cancel
      def cancel
        response = client.execute_request('subscription.cancel', {
          data: {
            subscription_id: self.subscription_id
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
  end
end