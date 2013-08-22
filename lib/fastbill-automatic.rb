require "version"
require "fastbill-automatic/client"
require "fastbill-automatic/resources/base"
require "fastbill-automatic/resources/customer"
require "fastbill-automatic/resources/invoice"
require "fastbill-automatic/resources/subscription"
require "fastbill-automatic/resources/article"
require "fastbill-automatic/resources/template"

module FastbillAutomatic
  # Default client used by all API resources unless a different
  # client is explizitly passed as argument.
  @@client = nil

  # Overwrites the default Client with the one passed as argument
  def self.client= client
    @@client = client
  end
  # Returns the default Client.
  #
  # If no client was set returns nil
  def self.client
    return @@client
  end
end