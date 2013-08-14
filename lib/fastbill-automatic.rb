require "version"
require "fastbill-automatic/client"
require "fastbill-automatic/customer"

module FastbillAutomatic
  @@client = nil
  def self.client= client
    @@client = client
  end
  def self.client
    return @@client
  end
end
