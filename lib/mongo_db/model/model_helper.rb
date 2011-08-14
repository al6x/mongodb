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
  
  def insert_with_model args, opts = {}
    docs = args.is_a?(Array) ? args : [args]
    result = _insert_with_model docs, opts
    args.is_a?(Array) ? result : result.first
  end
  
  def update_with_model selector, doc, opts = {}
    doc = Mongo::Ext::ModelHelper.convert_object_to_doc doc unless doc.is_a?(Hash)        
    update_without_model selector, doc, opts
  end

  def remove_with_model arg = {}, opts = {}
    if arg.is_a? Hash
      remove_without_model arg, opts
    else      
      id = arg.instance_variable_get(:@_id) || "can't remove object without _id (#{arg})!"
      remove_without_model({_id: id}, opts)
    end
  end
  
  
  #
  # Querying
  #  
  def first *args, &block
    doc = super *args, &block
    Mongo::Ext::ModelHelper.convert_doc_to_object doc
  end

  def each *args, &block
    super *args do |doc|
      doc = Mongo::Ext::ModelHelper.convert_doc_to_object(doc)
      block.call doc
    end
    nil
  end

  protected
    def _insert_with_model docs, opts
      hashes = docs.collect do |doc| 
        doc.is_a?(Hash) ? doc : Mongo::Ext::ModelHelper.convert_object_to_doc(doc)
      end
      result = insert_without_model hashes, opts
      hashes.each_with_index do |h, i| 
        Mongo::Ext::ModelHelper.update_object_after_insertion docs[i], h
      end
      result
    end
  
  
  SIMPLE_TYPES = [
    Fixnum, Float,
    TrueClass, FalseClass,
    String, Symbol, 
    Array, Hash, Set,
    Data, DateTime,
    NilClass, Time,
    BSON::ObjectId
  ].to_set
  
  class << self
    def update_object_after_insertion doc, hash
      return if doc.is_a? Hash      
      if id = hash[:_id] || hash['_id']    
        doc.instance_variable_set :@_id, id 
      end
    end
    
    # converts object to hash (also works with nested & arrays)
    def convert_object_to_doc obj
      return obj.to_mongo if obj.respond_to? :to_mongo

      if obj.is_a? Hash
        doc = {}
        obj.each do |k, v|
          doc[k] = convert_object_to_doc v          
        end
        doc
      elsif obj.is_a? Array
        obj.collect{|v| convert_object_to_doc v}
      elsif SIMPLE_TYPES.include? obj.class
        obj
      else
        doc = {}

        # copying instance variables to hash
        obj.instance_variables.each do |iv_name|
          # skipping variables starting with _xx, usually they
          # have specific meaning and used for example for cache
          next if iv_name =~ /^@_/ and iv_name != :@_id

          k = iv_name.to_s[1..-1]
          k = k.to_sym if Mongo.defaults[:symbolize]
          v = obj.instance_variable_get iv_name
          doc[k] = convert_object_to_doc v          
        end

        # setting class
        class_name = '_class'
        class_name = class_name.to_sym if Mongo.defaults[:symbolize]
        doc[class_name] = obj.class.name        

        doc
      end
    end
    
    def convert_doc_to_object doc
      if doc.is_a? Hash
        if class_name = doc[:_class] || doc['_class']
          klass = constantize class_name
          obj = klass.new
          doc.each do |k, v|
            next if k.to_sym == :_class

            v = convert_doc_to_object v
            obj.instance_variable_set "@#{k}", v
          end
          obj
        else
          doc
        end
      elsif doc.is_a? Array
        doc.collect{|v| convert_doc_to_object v}
      else
        doc
      end
    end
    
    def constantize class_name
      @constantize_cache ||= {}
      unless klass = @constantize_cache[class_name]
        klass = eval class_name, TOPLEVEL_BINDING, __FILE__, __LINE__
        @constantize_cache[class_name] = klass
      end
      klass
    end
  end    
end