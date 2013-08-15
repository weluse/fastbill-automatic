require 'test_helper'

class BaseTest < Minitest::Test
  attr_accessor :client
  class ExampleResource < ::FastbillAutomatic::Resources::Base
    attribute :id, Integer
    attribute :firstname, String

    def new?
      return self.id != nil
    end
  end

  def test_raises_error_for_unknown_attribute
    customer = ExampleResource.new({})
    assert_raises NoMethodError do
      customer.middle_name
    end
  end

  def test_attribute_getter
    customer = ExampleResource.new({
      :id => 42
    })
    assert customer.respond_to?(:id)
    assert_equal 42, customer.id
  end

  def test_attribute_setter
    customer = ExampleResource.new()
    assert_equal nil, customer.id

    assert customer.respond_to?(:id=)
    customer.id = 42
    assert_equal 42, customer.id
  end
end