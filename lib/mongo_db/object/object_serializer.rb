class Mongo::ObjectSerializer
  SIMPLE_TYPES = [
    Fixnum, Float,
    TrueClass, FalseClass,
    String, Symbol,
    Array, Hash, Set,
    Data, DateTime,
    NilClass, Time,
    BSON::ObjectId    
  ].to_set
  
  attr_reader :object
  
  def initialize object
    @object = object
  end
  
  def save opts, collection
    if id = object.instance_variable_get(:@_id)
      self.update opts.merge(upsert: true), collection
    else
      self.insert opts, collection
    end
  end
    
  def insert opts, collection
    validate_and_save opts do |opts|
      doc = to_document
      collection.insert_without_object doc, opts    
      id = doc[:_id] || doc['_id'] || raise("no id after document insertion (#{doc})!")
      object.instance_variable_set :@_id, id    
    end
  end
  
  def update opts, collection
    validate_and_save opts do |opts|
      doc = to_document
      id = _id || raise("can't update document without id (#{doc})!")
      collection.update_without_object({_id: id}, doc, opts)
    end
  end
  
  def remove opts, collection
    validate_and_save opts do |opts|
      id = _id || "can't remove object without _id (#{arg})!"
      collection.remove_without_object({_id: id}, opts)
    end
  end
  
  def to_document
    _to_document object
  end
  
  def _id
    object.instance_variable_get(:@_id)
  end
  
  def validate
    each_object{|obj| obj.respond_to?(:validate) && obj.validate}
  end
  
  def valid?
    each_object do |obj|
      return false if obj.respond_to?(:valid?) and !obj.valid?
    end
    true
  end
  
  def validate_and_save opts, &block
    opts = opts.clone
    validate = opts.delete(:validate) != false
    
    self.validate if validate
    if !validate or self.valid?
      block.call opts
      true
    else
      false
    end
  end
  
  def each_object &block
    _each_object object, &block
  end
  
  protected
    # need this to allow change it in specs
    # RSpec adds @mock_proxy, and we need to skip it
    SKIP_IV_REGEXP = /^@_/
    
    def _each_instance_variable obj, &block
      obj.instance_variables.each do |iv_name|
        # skipping variables starting with _xx, usually they
        # have specific meaning and used for example for cache
        next if iv_name =~ SKIP_IV_REGEXP
        
        block.call iv_name, obj.instance_variable_get(iv_name)
      end
    end
  
    # converts object to document (also works with nested & arrays)
    def _to_document obj
      return obj.to_mongo if obj.respond_to? :to_mongo
      
      if obj.is_a? Hash
        doc = {}
        obj.each do |k, v|
          doc[k] = _to_document v
        end
        doc
      elsif obj.is_a? Array
        obj.collect{|v| _to_document v}
      elsif SIMPLE_TYPES.include? obj.class
        obj
      else
        doc = {}

        # copying instance variables
        _each_instance_variable obj do |iv_name, v|
          k = iv_name.to_s[1..-1]
          k = k.to_sym if Mongo.defaults[:symbolize]
          doc[k] = _to_document v
        end
        
        # adding _id & _class
        id_key, class_key = Mongo.defaults[:symbolize] ? [:_id, :_class] : ['_id', '_class']
        id = instance_variable_get('@_id')        
        doc[id_key]    = id if id
        doc[class_key] = obj.class.name
        
        doc
      end
    end
  
    def _each_object obj, &block
      if obj.is_a? Hash        
        obj.each{|k, v| _each_object v, &block}
      elsif obj.is_a? Array
        obj.each{|v| _each_object v, &block}
      elsif SIMPLE_TYPES.include? obj.class        
      else
        block.call obj
        _each_instance_variable obj do |iv_name, v|
          _each_object v, &block
        end
      end
      nil
    end
end