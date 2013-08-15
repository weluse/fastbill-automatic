require "virtus"

module FastbillAutomatic
  module Resources
    class Base
      include Virtus

      # must be an instance of Client or compatible.
      #
      # The client is used to build and execute queries against FastbillAutomatic
      attr_reader :client

      # are set if an request to the FastbillAutomatic API failed. Most
      # of the time it will contain an Array of error messages.
      attr_reader :errors

      # Invokes either #create or #update, depending on the current state of the instance
      def save
        if new?
          return create()
        else
          return update()
        end
      end

      # Creates a new instance of Customer using passed attrs to initialize the
      # instance attributes
      def initialize attrs = Hash.new, client = FastbillAutomatic.client
        attrs.downcase_keys!
        attrs.symbolize_keys!
        super(attrs)

        @client = client
        @errors = []
      end
    end
  end
end