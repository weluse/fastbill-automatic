require 'json'

module FastbillAutomatic
  class Client
    SERVICE_URL = "https://my.fastbill.com/api/1.0/api.php"

    attr_accessor :email, :api_key
    def initialize email, api_key = nil
      @email = email
      @api_key = api_key
    end

    def login password
      request = build_request({}, {
        'X-Username' => email,
        'X-Password' => password
        })
      response = request.run

      if response.success?
        @api_key = JSON.parse(response.body)['api_key']
      end

      return response.success?
    end

    def build_body hash
      return {
        fbapi: hash
      }
    end

    def build_request options, headers = {}
      return ::Typhoeus::Request.new(
        SERVICE_URL, options.merge({
            :method => :post,
            :headers => {
              'Content-Type' => 'application/json'
            }.merge(headers)
          })
        )
    end
  end
end