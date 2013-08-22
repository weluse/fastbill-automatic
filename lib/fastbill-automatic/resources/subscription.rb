module FastbillAutomatic
  module Resources
    class Subscription < Base
      attribute :subscription_id, Integer
      attribute :article_number, Integer
      attribute :customer_id, Integer
      attribute :start, DateTime
      attribute :next_event, DateTime
      attribute :cancellation_date, DateTime
      attribute :status, String
      attribute :article_number, String
      attribute :subscription_ext_uid, String
      attribute :last_event, DateTime

      # optional: used to overwrite article attributes
      attribute :coupon, String
      attribute :title, String
      attribute :unit_price, BigDecimal
      attribute :currency_code, String

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
        results = self.all({ subscription_id: id }, client)
        return results.first || UnknownSubscription.new
      end

      # True if the subscription has been cancelled.
      def cancelled?
        return self.status == 'canceled'
      end

      # Decides if a Subscription is persisted by looking at its #subscription_id
      def new?
        return self.subscription_id.to_s == ''
      end

      def create
        response = client.execute_request('subscription.create', {
          data: self.attributes
        })

        if response.success? && response.fetch('status') == 'success'
          @errors = []
          self.subscription_id = response.fetch('subscription_id')
          return true
        end

        @errors = response.errors
        return false
      end

      def update
        response = client.execute_request('subscription.create', {
          data: self.attributes
        })

        if response.success? && response.fetch('status') == 'success'
          @errors = []
          self.next_event = response.fetch('next_event')
          self.subscription_ext_uid = response.fetch('subscription_ext_uid')
          return true
        end

        @errors = response.errors
        return false
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
