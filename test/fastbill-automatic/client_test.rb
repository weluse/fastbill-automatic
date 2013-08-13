require 'test_helper'

class ClientTest < MiniTest::Unit::TestCase
	def test_correct_service_url
    assert_equal "https://my.fastbill.com/api/1.0/api.php", ::FastbillAutomatic::Client::SERVICE_URL
	end
end