# fastbill-automatic

<!---
[![Gem Version](https://badge.fury.io/rb/fastbill-automatic.png)](http://badge.fury.io/rb/fastbill-automatic)
[![Build Status](https://travis-ci.org/weluse/fastbill-automatic.png?branch=master)](https://travis-ci.org/weluse/fastbill-automatic)
-->

Ruby wrapper for the FastBill Automatic API, Version 1.3 (15.01.2013).

## Integration

Add fastbill-automatic gem to your application's Gemfile

``` ruby
gem 'fastbill-automatic'
```

or install it

``` bash
$ gem install fastbill-automatic
```

## Usage

Before working with `Customer`, `Invoice` etc. you have to create a working client instance:

``` ruby
require 'fastbill-automatic'
::FastbillAutomatic.client = Client.new("<max@mustermann.de>", "<apikey>")
```

Afterwards you can easily list and search for existing Customers:

``` ruby
# retrieve all customers
all_customers = ::FastbillAutomatic::Resources::Customer.all()

# search for customers by city
customers_in_paris = ::FastbillAutomatic::Resources::Customer.all({ city: 'Paris' })

# load a specific Customer
the_customer = ::FastbillAutomatic::Resources::Customer.find_by_id(42)
```

Create, edit, update and delete Customers:

``` ruby
# update an existing Customer
any_customer = ::FastbillAutomatic::Resources::Customer.all().sample
any_customer.first_name = 'Max'
any_customer.last_name = 'Mustermann'
any_customer.save # automatically calls Customer#update

# create a new customer
new_customer = ::FastbillAutomatic::Resources::Customer.new({
  first_name: 'Maxi',
  last_name: 'Musterfrau'
})
new_customer.save # automatically calls Customer#create

# remove a customer from FastbillAutomatic
new_customer.destroy
```

Customers need to fullfil some constraints. If you make invalid requests you can access the error messages using `#error`

``` ruby
new_customer = ::FastbillAutomatic::Resources::Customer.new({
  customer_type: 'business'
})
new_customer.save # => false
new_customer.errors # => ['Organization is missing', 'Zipcode is missing', 'City is missing', 'Country_Code is missing']
```

Assuming you've already got a Customer you can list all Invoices:

``` ruby
# assuming we've got a customer
customer = ::FastbillAutomatic::Resources::Customer.all().sample

# fetch all invoices for a specific customer
invoices = ::FastbillAutomatic::Resources::Invoice.all({
  customer_id: customer.customer_id
})
```

Invoices can be managed as well:

``` ruby
# create a new invoice
invoice = ::FastbillAutomatic::Resources::Invoices.new({
  customer_id: customer.customer_id,
  currency_code: 'EUR',
  eu_delivery: true,
  items: [
    {
      description: 'Example',
      unit_price: 200.0,
      vat_percent: 19.0,
      quantity: 2
    }
  ]
})
invoice.save # => true

# change the price of an item
first_item = invoice.items.first
first_item.quantity = 4
first_item.unit_price = 50

invoice.save # => true

# remove all items
invoice.items = []
invoice.save # => true
```

## Development

This gem makes use of the **[minitest framework](https://github.com/seattlerb/minitestbundle)** and takes advantage of the guard adaption **[minitest-guard](https://github.com/guard/guard-minitest)** running tests automatically when files are modified. Run all tests with *Rake test* or run minitest-guard through Bundler with

``` bash
$ bundle exec guard
```

## Documentation

This gem is documented using [RDoc](http://rdoc.sourceforge.net/doc/). You can generated the entire documentation locally using
`bundle exec rake rdoc`.

## Contributing to fastbill-automatic

* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet.
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it.
* Fork the project.
* Start a feature/bugfix branch.
* Make sure to add tests for it.

## License

This gem is released under the [MIT License](http://www.opensource.org/licenses/MIT).