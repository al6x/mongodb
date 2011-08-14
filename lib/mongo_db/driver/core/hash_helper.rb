require 'set'
require 'date'

module Mongo::Ext::HashHelper
  #
  # CRUD
  #
  def save_with_ext doc, opts = {}
    save_without_ext doc, reverse_merge_defaults(opts, :safe)
  end

  def insert_with_ext doc_or_docs, opts = {}    
    result = insert_without_ext doc_or_docs, reverse_merge_defaults(opts, :safe)
    
    # fix for mongodriver, it will return single result if we supply [doc] as doc_or_docs
    result = [result] if doc_or_docs.is_a?(Array) and !result.is_a?(Array)
    result
  end

  def update_with_ext selector, document, opts = {}
    selector = convert_underscore_to_dollar_in_selector selector
    document = convert_underscore_to_dollar_in_update document

    # because :multi works only with $ operators, we need to check it
    opts = if document.keys.any?{|k| k =~ /^\$/}
      reverse_merge_defaults(opts, :safe, :multi)
    else
      reverse_merge_defaults(opts, :safe)
    end

    update_without_ext selector, document, opts
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
  def first spec_or_object_id = nil, opts = {}
    spec_or_object_id = convert_underscore_to_dollar_in_selector spec_or_object_id if spec_or_object_id.is_a? Hash

    h = find_one spec_or_object_id, opts
    symbolize_hash h
  end

  def all *args, &block
    if block
      each *args, &block
    else
      list = []
      each(*args){|o| list << o}
      list
    end
  end

  def each selector = {}, opts = {}, &block
    selector = convert_underscore_to_dollar_in_selector selector

    cursor = nil
    begin
      cursor = find selector, reverse_merge_defaults(opts, :batch_size)
      cursor.each do |h|
        h = symbolize_hash h
        block.call h
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
    def symbolize_hash o
      return o unless Mongo.defaults[:symbolize]
    
      convert_hash o do |k, v, result|
        k = k.to_sym if k.is_a? String
        result[k] = v
      end
    end

    # replaces :_lt to :$lt in query
    def convert_underscore_to_dollar_in_selector selector
      return selector unless Mongo.defaults[:convert_underscore_to_dollar]
    
      convert_hash selector do |k, v, result|
        k = "$#{k.to_s[1..-1]}".to_sym if QUERY_KEYWORDS.include?(k)
        result[k] = v
      end
    end

    # replaces :_set to :$set in query
    def convert_underscore_to_dollar_in_update update
      return update unless Mongo.defaults[:convert_underscore_to_dollar]
    
      convert_hash update do |k, v, result|
        k = "$#{k.to_s[1..-1]}".to_sym if UPDATE_KEYWORDS.include?(k)
        result[k] = v
      end
    end

    # converts hashes (also works with nested & arrays)
    def convert_hash o, &block
      if o.is_a? Hash
        result = {}
        o.each do |k, v|
          v = convert_hash v, &block
          block.call k, v, result
        end
        result
      elsif o.is_a? Array
        o.collect{|v| convert_hash v, &block}
      else
        o
      end
    end
end