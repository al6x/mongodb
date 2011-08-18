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
    if _id
      self.update opts.merge(upsert: true), collection
    else
      self.insert opts, collection
    end
  end

  def insert opts, collection
    opts, object_opts = parse_object_options opts

    run_validate_callbacks object_opts do
      run_callbacks :save, object_opts do
        run_create_callbacks object_opts do
          doc = to_document
          collection.insert_without_object doc, opts
          id = doc[:_id] || doc['_id'] || raise("internal error: no id after document insertion (#{doc})!")
          object.instance_variable_set :@_id, id
          update_internal_state!
        end
      end
    end
  end

  def update opts, collection
    opts, object_opts = parse_object_options opts

    run_validate_callbacks object_opts do
      run_callbacks :save, object_opts do
        run_update_callbacks object_opts do
          doc = to_document
          id = _id || raise("can't update document without id (#{doc})!")
          collection.update_without_object({_id: id}, doc, opts)
          update_internal_state!
        end
      end
    end
  end

  def remove opts, collection
    opts, object_opts = parse_object_options opts

    run_validate_callbacks object_opts do
      run_destroy_callbacks object_opts do
        id = _id || "can't destroy object without _id (#{arg})!"
        collection.remove_without_object({_id: id}, opts)
        update_internal_state!
      end
    end
  end

  def to_document
    _to_document object
  end

  def _id
    object.instance_variable_get(:@_id)
  end

  def valid?
    objects.each do |obj|
      return false if obj.respond_to?(:valid?) and !obj.valid?
    end
    true
  end

  def run_callbacks name, object_opts, objects = nil, &block
    unless object_opts[:callbacks]
      block.call
      return true
    end

    objects ||= self.objects

    before_name, after_name = "before_#{name}".to_sym, "after_#{name}".to_sym

    result = catch :halt do
      some_failed = false
      objects.each do |obj|
        if obj.respond_to? :run_callbacks
          result = obj.run_callbacks before_name

          some_failed = true if result == false
        end
      end

      throw :halt, false if some_failed

      throw :halt, false unless block.call

      objects.each do |obj|
        obj.run_callbacks after_name if obj.respond_to? :run_callbacks
      end

      true
    end
  end

  def objects
    @objects_cache ||= begin
      objects = []
      _each_object(object){|obj| objects << obj}
      objects
    end
  end

  def update_internal_state!
    self.original_embedded_objects = objects if Mongo.defaults[:callbacks]
  end

  def original_embedded_objects; object.instance_variable_get(:@_original_embedded_objects) end
  def original_embedded_objects= objects; object.instance_variable_set(:@_original_embedded_objects, objects) end

  protected
    def run_create_callbacks object_opts, &block
      run_callbacks :create, object_opts do
        block.call
        true
      end
    end

    def run_update_callbacks object_opts, &block
      # we need also run :create and :destroy callbacks on
      # inserted and removed embedded objects
      if object_opts[:callbacks]
        original_ids = original_embedded_objects.collect{|obj| obj.object_id}.to_set
        objects_ids = objects.collect{|obj| obj.object_id}.to_set
        created_objects = objects.select{|obj| !original_ids.include?(obj.object_id)}
        destroyed_objects = original_embedded_objects.select{|obj| !objects_ids.include?(obj.object_id)}
      else
        created_objects, destroyed_objects = [], []
      end

      run_callbacks :create, object_opts, created_objects do
        run_callbacks :destroy, object_opts, destroyed_objects do
          run_callbacks :update, object_opts do
            block.call
            true
          end
        end
      end
    end

    def run_destroy_callbacks object_opts, &block
      # we need also run :destroy callbacks on detached embedded objects
      all_objects = if object_opts[:callbacks]
        (objects + original_embedded_objects).uniq{|o| o.object_id}
      else
        nil
      end

      run_callbacks :destroy, object_opts, all_objects do
        block.call
        true
      end
    end

    def run_validate_callbacks object_opts, &block
      unless object_opts[:validate]
        block.call
        return true
      end

      run_callbacks :validate, object_opts do
        if valid?
          block.call
        else
          false
        end
      end
    end

    def parse_object_options opts
      opts = opts.clone
      object_opts = {
        validate: (opts.delete(:validate) == false ? false : true),
        callbacks: (opts.delete(:callbacks) == false ? false : Mongo.defaults[:callbacks])
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


  class << self
    def build doc
      obj = _build doc
      serializer = Mongo::ObjectSerializer.new obj
      serializer.update_internal_state!
      obj
    end

    protected
      def _build doc
        if doc.is_a? Hash
          if class_name = doc[:_class] || doc['_class']
            klass = constantize class_name

            if klass.respond_to? :to_object
              klass.to_object doc
            else
              obj = klass.new
              doc.each do |k, v|
                next if k.to_sym == :_class

                v = _build v
                obj.instance_variable_set "@#{k}", v
              end
              obj
            end
          else
            doc
          end
        elsif doc.is_a? Array
          doc.collect{|v| _build v}
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