module FastbillAutomatic
  module Resources
    # Subscription wraps subscription.get|update|create|changearticle access
    #
    # subscription.setaddon and subscription.setusagedata are currently not supported
    #
    # === TODO
    #
    # * add support for subscription.setaddon
    # * add support for subscription.setusagedata
    #
    # === Examples
    #   include ::FastbillAutomatic::Resources
    #
    #   # create a new subscription for an existing customer and a random article
    #   customer = Customer.all().sample
    #   subscription = Subscription.new({
    #     :customer_id => customer.id
    #     :article_number => Article.all().sample.id
    #   })
    #   subscription.save
    #
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

      # @transient
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

      # Returns the first subscription with a given subscription_id
      # or an instance of UnknownSubscription.
      def self.find_by_id subscription_id, client = FastbillAutomatic.client
        results = self.all({ subscription_id: subscription_id }, client)
        return results.first || UnknownSubscription.new
      end


      attr_reader :article_number_changed # :nodoc:
      def article_number= val # :nodoc:
        if !self.new? && val.to_s != self.article_number
          @article_number_changed = true
        end
        super
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
        # TODO support for addons?
        response = client.execute_request('subscription.create', {
          data: {
            subscription_ext_uid: subscription_ext_uid,
            article_number: article_number,
            customer_id: customer_id,
            coupon: coupon,
            title: title,
            unit_price: unit_price,
            currency_code: currency_code
          }
        })

        if response.success? && response.fetch('status') == 'success'
          @errors = []
          self.subscription_id = response.fetch('subscription_id')
          return true
        end

        @errors = response.errors
        return false
      end

      # executes subscription.update and if necessary subscription.changearticle
      def update
        if article_number_changed == true
          return execute_update && change_article
        end
        return execute_update
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

      # Invokes subscription.changearticle.
      #
      # This method is executed automatically for already persisted Subscriptions if you
      # changed the article_number using the setter.
      def change_article
        response = client.execute_request('subscription.changearticle', {
          data: {
            subscription_id: subscription_id,
            article_number: article_number,
            title: title,
            unit_price: unit_price,
            currency_code: currency_code
          }
        })

        if response.success? && response.fetch('status') == 'success'
          @errors = []
          return true
        end

        @errors = response.errors
        return false
      end

      protected
      def execute_update
        response = client.execute_request('subscription.create', {
          data: {
            subscription_id: subscription_id,
            next_event: next_event,
            subscription_ext_uid: subscription_ext_uid,
          }
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
    end

    class UnknownSubscription < Subscription
      def cancel; end
    end
  end
end
