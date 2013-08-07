require 'test_helper'

class ClientTest < MiniTest::Test
	def test_namespace
		assert Fastbill.is_a?(Module)
	end
end