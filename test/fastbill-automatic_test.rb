require 'test_helper'

class FastbillAutomaticTest < Minitest::Test
  def test_modul_hosts_default_client
    assert_equal nil, FastbillAutomatic.client

    FastbillAutomatic.client = 42
    assert_equal 42, FastbillAutomatic.client
  end
end