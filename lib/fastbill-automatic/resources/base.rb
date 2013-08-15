require "virtus"

module FastbillAutomatic
  module Resources
    # Abstracts common Resource behaviour using Virtus, and attributes used by all subclasses
    class Base
      include Virtus

      # Must be an instance of Client or compatible.
      #
      # The client is used to build and execute queries against FastbillAutomatic
      attr_reader :client

      # Are set if an request to the FastbillAutomatic API failed. Most
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

      # Each subclass must implement this method to check if it has already been persisted or not.
      def new?
        raise NotImplementedError
      end

      # Each subclass must implement this method
      def create
        raise NotImplementedError
      end

      # Each subclass must implement this method
      def update
        raise NotImplementedError
      end

      # Creates a new instance of Customer using passed attrs to initialize the
      # instance attributes
      def initialize attrs = Hash.new, client = FastbillAutomatic.client

        super prepare_hash!(attrs)

        @client = client
        @errors = []
      end

      private
      def prepare_hash! hash
        downcase!(hash)
        symbolize!(hash)
        hash
      end
      def symbolize! hash
        hash.keys.each do |key|
          value = hash.delete(key)
          symbolize!(value) if value.is_a?(Hash)
          value.map! { |item| symbolize!(item) } if value.is_a?(Array)
          hash[(key.to_sym rescue key) || key] = value
        end
        hash
      end

      def downcase! hash
        hash.keys.each do |key|
          value = hash.delete(key)
          downcase!(value) if value.is_a?(Hash)
          value.map! { |item| downcase!(item) } if value.is_a?(Array)
          hash[(key.to_s.downcase rescue key) || key] = value
        end
        hash
      end
    end
  end
end