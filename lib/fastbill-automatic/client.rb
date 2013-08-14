require 'json'
require 'typhoeus'

module FastbillAutomatic
  class Response
    def initialize success, body
      @success = success || false
      @body = body.fetch('RESPONSE', {})
    end

    def success?
      return @success
    end

    def errors
      return @body.fetch('ERRORS', [])
    end

    def fetch(key)
      return @body.fetch(key.upcase, nil)
    end
  end

  class Client
    SERVICE_URL = "https://automatic.fastbill.com/api/1.0/api.php"

    attr_accessor :email, :api_key
    def initialize email, api_key
      @email = email
      @api_key = api_key
    end

    def execute_request service, other = {}, headers = {}
      request = build_request(service, other, headers)
      response = request.run

      return Response.new(response.success?, JSON.parse(response.body))
    end

    def build_request service, other = {}, headers = {}
      return build_typhoeus_request({
          body: JSON.dump({
            service: service
          }.merge(other))
        }, headers)
    end

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