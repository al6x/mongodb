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

  QUERY_KEYWORDS = [
    :_lt, :_lte, :_gt, :_gte,
    :_all, :_exists, :_mod, :_ne, :_in, :_nin,
    :_nor, :_or, :_and,
    :_size, :_type
  ].to_set

  UPDATE_KEYWORDS = [
    :_inc, :_set, :_unset, :_push, :_pushAll, :_addToSet, :_pop, :_pull, :_pullAll, :_rename, :_bit
  ].to_set

  class << self
    # symbolizing hashes
    def symbolize o
      convert o do |k, v, result|
        k = k.to_sym if k.is_a? String
        result[k] = v
      end
    end

    # replaces :_lt to :$lt in query
    def convert_underscore_to_dollar_in_selector selector
      convert selector do |k, v, result|
        k = "$#{k.to_s[1..-1]}".to_sym if QUERY_KEYWORDS.include?(k)
        result[k] = v
      end
    end

    # replaces :_set to :$set in query
    def convert_underscore_to_dollar_in_update update
      convert update do |k, v, result|
        k = "$#{k.to_s[1..-1]}".to_sym if UPDATE_KEYWORDS.include?(k)
        result[k] = v
      end
    end

    # converts hashes (also works with nested & arrays)
    def convert o, &block
      if o.is_a? Hash
        result = {}
        o.each do |k, v|
          v = convert v, &block
          block.call k, v, result
        end
        result
      elsif o.is_a? Array
        o.collect{|v| convert v, &block}
      else
        o
      end
    end
  end
end