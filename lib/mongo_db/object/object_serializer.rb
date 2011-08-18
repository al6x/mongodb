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
    opts, object_opts = parse_object_options opts

    run_validate_callbacks object_opts do
      doc = to_document
      collection.insert_without_object doc, opts
      id = doc[:_id] || doc['_id'] || raise("internal error: no id after document insertion (#{doc})!")
      object.instance_variable_set :@_id, id
    end
  end

  def update opts, collection
    opts, object_opts = parse_object_options opts

    run_validate_callbacks object_opts do
      doc = to_document
      id = _id || raise("can't update document without id (#{doc})!")
      collection.update_without_object({_id: id}, doc, opts)
    end
  end

  def remove opts, collection
    opts, object_opts = parse_object_options opts

    run_validate_callbacks object_opts do
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

  def valid?
    each_object do |obj|
      return false if obj.respond_to?(:valid?) and !obj.valid?
    end
    true
  end

  def run_validate_callbacks object_opts, &block
    unless object_opts[:validate]
      block.call
      return true
    end

    run_callbacks :validate, object_opts do
      if valid?
        block.call
        true
      else
        false
      end
    end
  end

  def each_object &block
    _each_object object, &block
  end

  def run_callbacks name, object_opts, &block
    unless object_opts[:callbacks]
      block.call
      return true
    end

    before_name, after_name = "before_#{name}".to_sym, "after_#{name}".to_sym

    catch :halt do
      some_failed = false
      each_object do |obj|
        if obj.respond_to? :run_callbacks
          result = obj.run_callbacks before_name
          some_failed = true if result == false
        end
      end
      throw :halt, false if some_failed

      throw :halt, false unless block.call

      each_object do |obj|
        obj.run_callbacks after_name if obj.respond_to? :run_callbacks
      end

      true
    end
  end

  protected
    def parse_object_options opts
      opts = opts.clone
      object_opts = {
        validate: (opts.delete(:validate) == false ? false : true),
        callbacks: (opts.delete(:callbacks) == false ? false : true)
      }
      return opts, object_opts
    end

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