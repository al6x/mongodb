module Mongo::Ext::ModelHelper
  #
  # CRUD
  #
  def save_with_model doc, opts = {}
    if doc.is_a? Hash
      save_without_model doc, opts
    else
      if id = doc.instance_variable_get(:@_id)
        update({:_id => id}, doc, opts.merge(upsert: true))
      else
        insert doc, opts
      end
    end
  end
  
  def insert_with_model doc_or_docs, opts = {}
    docs = doc_or_docs.is_a?(Array) ? doc_or_docs : [doc_or_docs]
    result = _insert_with_model docs, opts
    result = result.first unless doc_or_docs.is_a?(Array)
    result
  end
  
  def _insert_with_model docs, opts
    hashes = docs.collect{|doc| doc.is_a?(Hash) ? doc : convert_object_to_hash(doc)}
    result = insert_without_model hashes, opts
    hashes.each_with_index{|h, i| update_object_after_insertion docs[i], h}
    result
  end

  def update_with_model selector, document, opts = {}
    # checking is it document or atomic update
    document = convert_object_to_hash document unless document.is_a?(Hash) and document.keys.any?{|k| k =~ /^\$/}
        
    update_without_model selector, document, opts
  end

  def remove_with_model selector = {}, opts = {}
    if selector.is_a? Hash    
      remove_without_model selector, opts
    else
      id = selector.instance_variable_get(:@_id) || "can't remove object without _id (#{selector})!"
      remove_without_model({_id: id}, opts)
    end
  end
  
  
  #
  # Querying
  #  
  def first *args, &block
    h = super *args, &block
    convert_hash_to_object h
  end

  def each *args, &block
    selector = convert_underscore_to_dollar_in_selector selector
    super *args do |h|
      o = convert_hash_to_object(h)
      block.call o
    end
    nil
  end

  protected
    SIMPLE_TYPES = [
      Fixnum, Float,
      TrueClass, FalseClass,
      String, Symbol, 
      Array, Hash, Set,
      Data, DateTime,
      NilClass, Time,
      BSON::ObjectId
    ].to_set
  
    def update_object_after_insertion hash_or_object, hash
      return if hash_or_object.is_a? Hash      
      obj = hash_or_object
      
      if id = hash[:_id] || hash['_id']    
        obj.instance_variable_set :@_id, id
      end      
      nil
    end
    
    # converts object to hash (also works with nested & arrays)
    def convert_object_to_hash o
      return o.to_mongo if o.respond_to? :to_mongo
      
      if o.is_a? Hash
        result = {}
        o.each do |k, v|
          result[k] = convert_object_to_hash v          
        end
        result
      elsif o.is_a? Array
        o.collect{|v| convert_object_to_hash v}
      elsif SIMPLE_TYPES.include? o.class
        o
      else
        result = {}
        
        # copying instance variables to hash
        o.instance_variables.each do |iv_name|
          # skipping variables starting with _xx, usually they
          # have specific meaning and used for example for cache
          next if iv_name =~ /^@_/ and iv_name != :@_id
          
          k = iv_name.to_s[1..-1]
          k = k.to_sym if Mongo.defaults[:symbolize]
          v = o.instance_variable_get iv_name
          result[k] = convert_object_to_hash v          
        end
        
        # setting class
        class_name = '_class'
        class_name = class_name.to_sym if Mongo.defaults[:symbolize]
        result[class_name] = o.class.name        
        
        result
      end
    end
    
    def convert_hash_to_object o
      if o.is_a? Hash
        if class_name = o[:_class] || o['_class']
          klass = Mongo::Ext::ModelSerializer.constantize class_name
          result = klass.new
          o.each do |k, v|
            next if k.to_sym == :_class
            
            v = convert_hash_to_object v
            result.instance_variable_set "@#{k}", v
          end
          result
        else
          o
        end
      elsif o.is_a? Array
        o.collect{|v| convert_hash_to_object v}
      else
        o
      end
    end
end