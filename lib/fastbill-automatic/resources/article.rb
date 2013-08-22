module FastbillAutomatic
  module Resources
    class Article < Base
      attribute :article_number, Integer
      attribute :title, String
      attribute :description, String
      attribute :unit_price, BigDecimal
      attribute :allow_multiple, Boolean
      attribute :is_addon, Boolean
      attribute :currency_code, String
      attribute :vat_percent, Float
      attribute :setup_fee, BigDecimal
      attribute :subscription_interval, String
      attribute :subscription_number_events, Integer
      attribute :subscription_trial, Integer
      attribute :subscription_duration, String
      attribute :subscription_cancellation, String
      attribute :return_url_success, String
      attribute :return_url_cancel, String
      attribute :checkout_url, String

      # Returns an Enumerable containing Article objects.
      def self.all filter = {}, client = FastbillAutomatic.client
        response = client.execute_request('article.get', { filter: filter })

        results = []
        if response.success?
          results = response.fetch('articles').map { |data| self.new(data, client) }
        else
          # TODO handle error case
          p response.errors
        end
        return results
      end
    end
  end
end
