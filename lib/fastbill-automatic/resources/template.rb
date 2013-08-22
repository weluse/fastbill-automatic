module FastbillAutomatic
  module Resources
    # Template wraps interaction with template.get
    #
    # Currently templates are read only.
    #
    # === Examples
    #   include ::FastbillAutomatic::Resources
    #
    #   # read all known Templates
    #   templates = Template.all()
    #
    class Template < Base
      attribute :template_id, Integer
      attribute :template_name, String

      alias_method :id, :template_id
      alias_method :id=, :template_id=

      # Returns an Enumerable containing Template objects.
      def self.all client = FastbillAutomatic.client
        response = client.execute_request('template.get', {})

        results = []
        if response.success?
          results = response.fetch('templates').map { |data| self.new(data, client) }
        else
          # TODO handle error case
          p response.errors
        end
        return results
      end
    end
  end
end
