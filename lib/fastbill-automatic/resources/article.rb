module FastbillAutomatic
  module Resources
    class Article < Base
      # Returns an Enumerable containing Article objects.
      #
      # filter supports the following keys:
      # * article_id      same as .find_by_id
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