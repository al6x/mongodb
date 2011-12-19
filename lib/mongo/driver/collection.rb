require 'set'
require 'date'

module Mongo::CollectionExt
  # CRUD.

  def save_with_ext doc, options = {}
    save_without_ext doc, reverse_merge_defaults(options, :safe)
  end

  def insert_with_ext args, options = {}
    result = insert_without_ext args, reverse_merge_defaults(options, :safe)

    # For some strange reason MongoDB Ruby driver
    # uses Strings for all keys but _id.
    # It's inconvinient, fixing it.
    if Mongo.defaults[:convert_id_to_string]
      list = args.is_a?(Array) ? args : [args]
      list.each{|h| h['_id'] = h.delete :_id}
    end

    # Fix for mongodriver, it will return single result if we supply [doc] as args.
    (args.is_a?(Array) and !result.is_a?(Array)) ? [result] : result
  end

  def update_with_ext selector, doc, options = {}
    selector = convert_underscore_to_dollar_in_selector selector
    doc      = convert_underscore_to_dollar_in_update doc

    # because :multi works only with $ operators, we need to check if it's applicable
    options = if doc.keys.any?{|k| k =~ /^\$/}
      reverse_merge_defaults(options, :safe, :multi)
    else
      reverse_merge_defaults(options, :safe)
    end

    update_without_ext selector, doc, options
  end

  def remove_with_ext selector = {}, options = {}
    selector = convert_underscore_to_dollar_in_selector selector
    remove_without_ext selector, reverse_merge_defaults(options, :safe, :multi)
  end

  def delete *args
    remove *args
  end

  def create *args
    insert *args
  end

  # Querying.

  def first selector = {}, options = {}
    selector = convert_underscore_to_dollar_in_selector selector if selector.is_a? Hash
    find_one selector, options
  end

  def first! selector = {}, options = {}
    first(selector, options) || raise(Mongo::NotFound, "document with selector #{selector} not found!")
  end

  def all selector = {}, options = {}, &block
    if block
      each selector, options, &block
    else
      list = []
      each(selector, options){|doc| list << doc}
      list
    end
  end

  def each selector = {}, options = {}, &block
    selector = convert_underscore_to_dollar_in_selector selector

    cursor = nil
    begin
      cursor = find selector, reverse_merge_defaults(options, :batch_size)
      cursor.each do |doc|
        block.call doc
      end
      nil
    ensure
      cursor.close if cursor
    end
    nil
  end

  def count_with_ext selector = {}, options = {}
    selector = convert_underscore_to_dollar_in_selector selector if selector.is_a? Hash
    find(selector, options).count()
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

    def reverse_merge_defaults options, *keys
      h = options.clone
      keys.each do |k|
        h[k] = Mongo.defaults[k] if Mongo.defaults.include?(k) and !h.include?(k)
      end
      h
    end

    # Replaces :_lt to :$lt in query.
    def convert_underscore_to_dollar_in_selector selector
      return selector unless Mongo.defaults[:convert_underscore_to_dollar]

      Mongo::CollectionExt.convert_doc selector do |k, v, result|
        k = "$#{k.to_s[1..-1]}".to_sym if QUERY_KEYWORDS.include?(k)
        result[k] = v
      end
    end

    # Replaces :_set to :$set in query.
    def convert_underscore_to_dollar_in_update update
      return update unless Mongo.defaults[:convert_underscore_to_dollar]

      Mongo::CollectionExt.convert_doc update do |k, v, result|
        k = "$#{k.to_s[1..-1]}".to_sym if UPDATE_KEYWORDS.include?(k)
        result[k] = v
      end
    end

    # Walks on hash and creates another (also works with nested & arrays).
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