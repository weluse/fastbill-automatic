require 'test_helper'

class ArticleTest < Minitest::Test
  attr_accessor :client
  def setup
    @client = ::FastbillAutomatic.client = ::FastbillAutomatic::Client.new("max@mustermann.de", "nopass123")
  end
  def teardown
    ::FastbillAutomatic.client = nil
  end
end