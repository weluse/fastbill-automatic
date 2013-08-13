module FastbillAutomatic
  class Client
    SERVICE_URL = "https://my.fastbill.com/api/1.0/api.php"

    attr_accessor :config
    def initialize config
      @config = config
    end
  end
end