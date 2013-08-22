# fastbill-automatic

<!---
[![Gem Version](https://badge.fury.io/rb/fastbill-automatic.png)](http://badge.fury.io/rb/fastbill-automatic)
[![Build Status](https://travis-ci.org/weluse/fastbill-automatic.png?branch=master)](https://travis-ci.org/weluse/fastbill-automatic)
-->

Ruby wrapper for the FastBill Automatic API, Version 1.5 (05.08.2013).
Please note that there are major differences between the Fastbill and Fastbill Automatic API,
and this Gem only works for Fastbill Automatic.

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

Afterwards you can easily start using all available classes etc.

``` ruby
include ::FastbillAutomatic::Resources
customers = Customer.all()
invoices = Invoice.all()
subscriptions = Subscription.all()
```

At the time of writing you can use this library to manage customers, create invoices and to create and manage subscriptions.
See below for a list of not implemented API features.

A more detailed usage example is included in RDoc.

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

## TODO

* add support for item.get and item.delete.
  Items are managed by the Invoice right now, and some users might want more granular control.
* add support for invoice.sign
  You can not sign your invoice using this gem ATM
* add support for invoice.sendbypost
  Invoices can only be delivered by email right now
* add support for invoice.setpaid

## License

This gem is released under the [MIT License](http://www.opensource.org/licenses/MIT).