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

      # Same as .all with subscription_id as filter
      def self.find_by_id id, client = FastbillAutomatic.client
        response = client.execute_request('subscription.get', { filter: { subscription_id: id } })

        if response.success? && (subscription_data = response.fetch('subscriptions')).length > 0
          return self.new(subscription_data[0], client)
        else
          return UnknownSubscription.new
        end
      end

      # True if the subscription has been cancelled.
      def cancelled?
        return self.status == 'canceled'
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
          self.cancellation_date = response.fetch('cancellation_date')
          return true
        end

        @errors = response.errors
        return false
      end
    end

    class UnknownSubscription < Subscription
      def cancel; end
    end
  end
end
