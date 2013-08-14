require 'test_helper'

class ClientTest < Minitest::Test
	def test_correct_service_url
    assert_equal "https://automatic.fastbill.com/api/1.0/api.php", ::FastbillAutomatic::Client::SERVICE_URL
	end

  def test_passes_content_type_json
    client = ::FastbillAutomatic::Client.new("max@mustermann.de", "nopass123")

    request = client.build_request({})
    assert_equal 'application/json', request.options[:headers]['Content-Type']
  end
end