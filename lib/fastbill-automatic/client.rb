require 'json'
require 'typhoeus'

module FastbillAutomatic
  #
  class Response
    attr_reader :body
    def initialize success, body
      @success = success || false
      @body = body.fetch('RESPONSE', {})
    end

    def success?
      return @success && errors.empty?
    end

    def errors
      return fetch('errors') || []
    end

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

    # Creates a new instance of ::FastbillAutomatic::Client, assigning both
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
    # Responses are wrapped using ::FastbillAutomatic::Response
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