require 'json'
require 'typhoeus'

module FastbillAutomatic
  # Wraps the result of a Typhoeus response.
  #
  # This class only allows access to the FastbillAutomatic RESPONSE.
  # Fastbill also sends along the original request body, but this
  # part is ignored.
  class Response
    attr_reader :body
    # The client initializes each Response using the
    # HTTP Status Code, and the entire response body.
    def initialize success, body
      @success = success || false
      @body = body.fetch('RESPONSE', {})
    end

    # Returns true if the HTTP Status code was 200, and no errors were present in the response
    def success?
      return @success && errors.empty?
    end

    # Returns an Array containing all errors present in the response.
    def errors
      return fetch('errors') || []
    end

    # Returns an item from the response body.
    def fetch(key)
      return @body.fetch(key.upcase, nil)
    end
  end

  # Executes requests against the FastbillAutomatic API.
  #
  # When creating instances of Client you need to pass along your current
  # FastbillAutomatic email address, as well as a valid api_key.
  class Client
    SERVICE_URL = "https://automatic.fastbill.com/api/1.0/api.php"

    # The FastbillAutomatic email address used to log in with FastbillAutomatic
    attr_reader :email

    # The FastbillAutomatic api_key as displayed in your FastbillAutomatic profil page
    attr_reader :api_key

    # Creates a new instance of Client, assigning both
    # :email and :api_key.
    #
    # Most likely you'll want to assign the returned instance to
    # ::FastbillAutomatic.client to use it as the default client.
    #
    # Alternativly you can pass the client as an argument to most
    # methods that execute network requests.
    def initialize email, api_key
      @email = email
      @api_key = api_key
    end

    # Synchronously executes a request against the FastbillAutomatic API using
    # Typhoeus.
    #
    # Responses are wrapped using Response
    def execute_request service, other = {}, headers = {}
      request = build_request(service, other, headers)
      response = request.run

      if Typhoeus::Config.verbose
        puts request.options
        puts response.body
      end

      return Response.new(response.success?, JSON.parse(response.body))
    end

    # When you need more control over each request you can use this method
    # to receive a ::Typhoeus::Request instance which you manually need to
    # execute.
    def build_request service, other = {}, headers = {}
      return build_typhoeus_request({
          body: JSON.dump({
            service: service
          }.merge(other))
        }, headers)
    end

    protected

    def build_typhoeus_request options, headers = {}
      return ::Typhoeus::Request.new(
        SERVICE_URL, options.merge({
            :method => :post,
            :userpwd => "#{email}:#{api_key}",
            :headers => {
              "Content-Type" => 'application/json'
            }.merge(headers)
          })
        )
    end
  end
end