require 'set'
require 'date'

class Mongo::Ext::HashHelper
  # SIMPLE_TYPES = [
  #   String, Symbol, 
  #   Numeric, 
  #   Regexp, 
  #   Array, 
  #   TrueClass, FalseClass, 
  #   Date, DateTime,
  #   BSON::ObjectId
  # ].to_set

  class << self
    # symbolizing hashes
    def unmarshal o
      return o unless Mongo.defaults[:symbolize]
      
      if o.is_a? Hash
        h = {}
        o.each do |k, v|
          k = k.to_sym if k.is_a?(String)
          h[k] = unmarshal v
        end
        h
      elsif o.is_a? Array
        o.collect{|v| unmarshal v}
      else        
        o
      end
    end
  end
end