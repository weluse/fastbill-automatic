require "version"
require "fastbill-automatic/client"
require "fastbill-automatic/customer"
require "fastbill-automatic/invoice"

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
