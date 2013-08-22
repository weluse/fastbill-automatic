require 'test_helper'

class ArticleTest < Minitest::Test
  include ::FastbillAutomatic::Resources

  attr_accessor :client

  def setup
    @client = ::FastbillAutomatic.client = ::FastbillAutomatic::Client.new("max@mustermann.de", "nopass123")
  end

  def teardown
    ::FastbillAutomatic.client = nil
  end

  def test_parses_correctly
    response = Typhoeus::Response.new(code: 200, body: IO.read('test/fixtures/article_get_success.json'))
    Typhoeus.stub(/automatic.fastbill.com/).and_return(response)

    articles = Article.all()

    refute articles.empty?
    assert_equal 1, articles.size

    article = articles.first
    assert_equal 1, article.id
    assert_equal "Premium / Monat", article.title
    assert_equal "", article.description
    assert_equal 15.0, article.unit_price
    assert_equal true, article.allow_multiple
    assert_equal false, article.is_addon
    assert_equal "EUR", article.currency_code
    assert_equal 19.00, article.vat_percent
    assert_equal 42.99, article.setup_fee
    assert_equal "1 month", article.subscription_interval
    assert_equal 1, article.subscription_number_events
    assert_equal 2, article.subscription_trial
    assert_equal "3 month", article.subscription_duration
    assert_equal "2 month", article.subscription_cancellation
    assert_equal "http://example.com/plans/confirm_change", article.return_url_success
    assert_equal "http://example.com/plans/cancel_change", article.return_url_cancel
    assert_equal "https://automatic.fastbill.com/index.php?cmd=1001&token=asd&productId=1", article.checkout_url
  end
end