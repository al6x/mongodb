require 'set'
require 'date'

module Mongo::Ext::Collection
  #
  # CRUD
  #
  def save_with_ext doc, opts = {}
    save_without_ext doc, reverse_merge_defaults(opts, :safe)
  end

  def insert_with_ext args, opts = {}
    result = insert_without_ext args, reverse_merge_defaults(opts, :safe)

    # fix for mongodriver, it will return single result if we supply [doc] as args
    (args.is_a?(Array) and !result.is_a?(Array)) ? [result] : result
  end

  def update_with_ext selector, doc, opts = {}
    selector = convert_underscore_to_dollar_in_selector selector
    doc      = convert_underscore_to_dollar_in_update doc

    # because :multi works only with $ operators, we need to check if it's applicable
    opts = if doc.keys.any?{|k| k =~ /^\$/}
      reverse_merge_defaults(opts, :safe, :multi)
    else
      reverse_merge_defaults(opts, :safe)
    end

    update_without_ext selector, doc, opts
  end

  def remove_with_ext selector = {}, opts = {}
    selector = convert_underscore_to_dollar_in_selector selector
    remove_without_ext selector, reverse_merge_defaults(opts, :safe, :multi)
  end

  def destroy *args
    remove *args
  end

  #
  # Querying
  #
  def first selector = nil, opts = {}
    selector = convert_underscore_to_dollar_in_selector selector if selector.is_a? Hash

    h = find_one selector, opts
    symbolize_doc h
  end

  def all *args, &block
    if block
      each *args, &block
    else
      list = []
      each(*args){|doc| list << doc}
      list
    end
  end

  def each selector = {}, opts = {}, &block
    selector = convert_underscore_to_dollar_in_selector selector

    cursor = nil
    begin
      cursor = find selector, reverse_merge_defaults(opts, :batch_size)
      cursor.each do |doc|
        doc = symbolize_doc doc
        block.call doc
      end
      nil
    ensure
      cursor.close if cursor
    end
    nil
  end

  protected
    QUERY_KEYWORDS = [
      :_lt, :_lte, :_gt, :_gte,
      :_all, :_exists, :_mod, :_ne, :_in, :_nin,
      :_nor, :_or, :_and,
      :_size, :_type
    ].to_set

    UPDATE_KEYWORDS = [
      :_inc, :_set, :_unset, :_push, :_pushAll, :_addToSet, :_pop, :_pull, :_pullAll, :_rename, :_bit
    ].to_set

    def reverse_merge_defaults opts, *keys
      h = opts.clone
      keys.each do |k|
        h[k] = Mongo.defaults[k] if Mongo.defaults.include?(k) and !h.include?(k)
      end
      h
    end

    # symbolizing hashes
    def symbolize_doc doc
      return doc unless Mongo.defaults[:symbolize]

      Mongo::Ext::Collection.convert_doc doc do |k, v, result|
        k = k.to_sym if k.is_a? String
        result[k] = v
      end
    end

    # replaces :_lt to :$lt in query
    def convert_underscore_to_dollar_in_selector selector
      return selector unless Mongo.defaults[:convert_underscore_to_dollar]

      Mongo::Ext::Collection.convert_doc selector do |k, v, result|
        k = "$#{k.to_s[1..-1]}".to_sym if QUERY_KEYWORDS.include?(k)
        result[k] = v
      end
    end

    # replaces :_set to :$set in query
    def convert_underscore_to_dollar_in_update update
      return update unless Mongo.defaults[:convert_underscore_to_dollar]

      Mongo::Ext::Collection.convert_doc update do |k, v, result|
        k = "$#{k.to_s[1..-1]}".to_sym if UPDATE_KEYWORDS.include?(k)
        result[k] = v
      end
    end

    # walks on hash and creates another (also works with nested & arrays)
    def self.convert_doc doc, &block
      if doc.is_a? Hash
        result = {}
        doc.each do |k, v|
          v = convert_doc v, &block
          block.call k, v, result
        end
        result
      elsif doc.is_a? Array
        doc.collect{|v| convert_doc v, &block}
      else
        doc
      end
    end
end