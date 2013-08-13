require 'test_helper'

class ClientTest < MiniTest::Unit::TestCase
	def test_correct_service_url
    assert_equal "https://my.fastbill.com/api/1.0/api.php", ::FastbillAutomatic::Client::SERVICE_URL
	end

  def test_handles_user_login
    response = ::Typhoeus::Response.new(code: 200, body: JSON.dump({ api_key: 'paul' }))
    ::Typhoeus.stub(/my\.fastbill\.com/).and_return(response)

    client = ::FastbillAutomatic::Client.new("max@mustermann.de")
    assert client.login("nopass123")

    assert_equal client.api_key, "paul"
  end

  def test_passes_content_type_json
    client = ::FastbillAutomatic::Client.new("max@mustermann.de", "nopass123")
  end
end