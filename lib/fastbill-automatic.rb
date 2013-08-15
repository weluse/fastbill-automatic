require "version"
require "fastbill-automatic/client"
require "fastbill-automatic/resources/base"
require "fastbill-automatic/resources/customer"
require "fastbill-automatic/resources/invoice"

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

if !Hash.new.respond_to?(:'symbolize_keys!')
  class Hash
    def symbolize_keys!
      keys.each do |key|
        value = delete(key)
        value.symbolize_keys! if value.is_a?(Hash)
        value.map! { |item| item.symbolize_keys! } if value.is_a?(Array)
        self[(key.to_sym rescue key) || key] = value
      end
      self
    end
  end
end
if !Hash.new.respond_to?(:'downcase_keys!')
  class Hash
    def downcase_keys!
      keys.each do |key|
        value = delete(key)
        value.downcase_keys! if value.is_a?(Hash)
        value.map! { |item| item.downcase_keys! } if value.is_a?(Array)
        self[(key.to_s.downcase rescue key) || key] = value
      end
      self
    end
  end
end