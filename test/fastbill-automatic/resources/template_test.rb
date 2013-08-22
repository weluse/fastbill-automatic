require 'test_helper'

class TemplateTest < Minitest::Test
  include ::FastbillAutomatic::Resources

  attr_accessor :client

  def setup
    @client = ::FastbillAutomatic.client = ::FastbillAutomatic::Client.new("max@mustermann.de", "nopass123")
  end

  def teardown
    ::FastbillAutomatic.client = nil
  end

  def test_parses_correctly
    response = Typhoeus::Response.new(code: 200, body: IO.read('test/fixtures/template_get_success.json'))
    Typhoeus.stub(/automatic.fastbill.com/).and_return(response)

    templates = Template.all()

    refute templates.empty?
    assert_equal 2, templates.size

    template = templates.first
    assert_equal 3063, template.id
    assert_equal "Englischsprachige Vorlage", template.template_name
  end
end