module Mongo::Object
  attr_accessor :_id, :_parent

  def valid? options = {}
    options = ::Mongo::Object.parse_options options
    begin
      return false if options[:callbacks] and !::Mongo::Object.run_before_callbacks(self, :validate)

      child_options = options.merge internal: true
      result = [
        child_objects.all?{|group| group.all?{|obj| obj.valid?(child_options)}},
        ::Mongo::Object.run_validations(self),
        errors.empty?
      ].all?

      ::Mongo::Object.run_after_callbacks(self, :validate) if options[:callbacks]

      result
    ensure
      clear_child_objects unless options[:internal]
    end
  end

  def errors
    @_errors ||= {}
  end

  def create_object collection, options
    with_object_callbacks :create, options do |options|
      doc = ::Mongo::Object.to_mongo self
      collection.create(doc, options)
      self._id = doc['_id']
    end
  end

  def update_object collection, options
    with_object_callbacks :update, options do |options|
      id = _id || "can't update object without _id (#{self})!"
      doc = ::Mongo::Object.to_mongo self
      collection.update({_id: id}, doc, options)
    end
  end

  def destroy_object collection, options
    with_object_callbacks :destroy, options do |options|
      id = _id || "can't destroy object without _id (#{self})!"
      collection.destroy({_id: id}, options)
    end
  end

  def save_object collection, options
    if _id
      update_object collection, options
    else
      create_object collection, options
    end
  end

  # need this to allow change it in specs
  # RSpec adds @mock_proxy, and we need to skip it
  SKIP_IV_REGEXP = /^@_/

  class << self
    def parse_options options
      options = options.clone
      options[:validate]  = true                       unless options.include?(:validate)
      options[:callbacks] = Mongo.defaults[:callbacks] unless options.include?(:callbacks)
      return options
    end

    def to_mongo_options options
      options = options.clone
      options.delete :validate
      options.delete :callbacks
      options
    end

    def each_object_instance_variable obj, &block
      obj.instance_variables.each do |iv_name|
        # skipping variables starting with _xx, usually they
        # have specific meaning and used for example for cache
        next if iv_name =~ SKIP_IV_REGEXP

        block.call iv_name, obj.instance_variable_get(iv_name)
      end
    end

    # converts object to document (also works with nested & arrays)
    def to_mongo obj
      return obj.to_mongo if obj.respond_to? :to_mongo

      if obj.is_a? Hash
        doc = {}
        obj.each do |k, v|
          doc[k] = to_mongo v
        end
        doc
      elsif obj.is_a? Array
        obj.collect{|v| to_mongo v}
      elsif obj.is_a? Mongo::Object
        doc = {}

        # copying instance variables
        each_object_instance_variable obj do |iv_name, v|
          k = iv_name.to_s[1..-1]
          doc[k] = to_mongo v
        end

        # adding _id & _class
        id = instance_variable_get('@_id')
        doc['_id']    = id if id
        doc['_class'] = obj.class.name

        doc
      else # simple type
        obj
      end
    end

    def each_object obj, include_first = true, &block
      if obj.is_a? Hash
        obj.each{|k, v| each_object v, &block}
      elsif obj.is_a? Array
        obj.each{|v| each_object v, &block}
      elsif obj.is_a? ::Mongo::Object
        block.call obj if include_first
        each_object_instance_variable obj do |iv_name, v|
          each_object v, &block
        end
      end
      nil
    end

    def build doc
      return unless doc
      obj = _build doc, nil
      obj.send :update_original_children! if obj.is_a? ::Mongo::Object
      obj
    end

    def run_before_callbacks obj, method
      if obj.respond_to?(:run_before_callbacks)
        obj.run_before_callbacks(:save, method: :save) if method == :update or method == :create
        obj.run_before_callbacks(method, method: method)
      else
        true
      end
    end

    def run_after_callbacks obj, method
      if obj.respond_to?(:run_before_callbacks)
        obj.run_after_callbacks(method, method: method)
        obj.run_after_callbacks(:save, method: :save) if method == :update or method == :create
      else
        true
      end
    end

    def run_validations obj
      obj.respond_to?(:run_validations) ? obj.run_validations : true
    end

    protected
      def _build doc, parent = nil
        if doc.is_a? Hash
          if class_name = doc[:_class] || doc['_class']
            klass = constantize class_name

            if klass.respond_to? :from_mongo
              obj = klass.from_mongo doc
            else
              obj = klass.new
              parent ||= obj
              doc.each do |k, v|
                next if k.to_sym == :_class

                v = _build v, parent
                obj.instance_variable_set "@#{k}", v
              end
              obj
            end
            obj._parent = parent if parent
            obj
          else
            hash = {}
            doc.each{|k, v| hash[k] = _build v, parent}
            hash
          end
        elsif doc.is_a? Array
          doc.collect{|v| _build v, parent}
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

  protected
    attr_writer :original_children
    def original_children; @_original_children ||= [] end

    def update_original_children!
      return unless ::Mongo.defaults[:callbacks]

      original_children.clear
      ::Mongo::Object.each_object self, false do |obj|
        original_children << obj
      end
    end

    def clear_child_objects
      if instance_variable_get(:@_child_objects)
        child_objects.each do |group|
          group.each{|obj| obj.clear_child_objects}
        end
        remove_instance_variable :@_child_objects
      end
    end

    def child_objects
      unless @_child_objects
        created_children, updated_children, destroyed_children = [], [], []

        original_children_ids = Set.new; original_children.each{|obj| original_children_ids << obj.object_id}
        ::Mongo::Object.each_object self, false do |obj|
          (original_children_ids.include?(obj.object_id) ? updated_children : created_children) << obj
        end

        children_ids = Set.new; ::Mongo::Object.each_object(self, false){|obj| children_ids << obj.object_id}
        destroyed_children = original_children.select{|obj| !children_ids.include?(obj.object_id)}

        @_child_objects = [created_children, updated_children, destroyed_children]
      end
      @_child_objects
    end

    def with_object_callbacks method, options, &block
      options = ::Mongo::Object.parse_options options

      # validation
      return false if options[:validate] and !valid?(options.merge(internal: true))

      # before callbacks
      return false if options[:callbacks] and !run_all_callbacks(:before, method)

      # saving
      block.call ::Mongo::Object.to_mongo_options(options)
      update_original_children!

      # after callbacks
      run_all_callbacks :after, method if options[:callbacks]

      true
    ensure
      clear_child_objects
    end

    # TODO1 move to static method
    def run_all_callbacks type, method
      result = if type == :before
        ::Mongo::Object.run_before_callbacks self, method
      else
        true
      end

      result &= if method == :create
        child_objects.all? do |group|
          group.all? do |obj|
            obj.run_all_callbacks type, method
          end
        end
      elsif method == :update
        created_children, updated_children, destroyed_children = child_objects
        created_children.all?{|obj| obj.run_all_callbacks type, :create} and
          updated_children.all?{|obj| obj.run_all_callbacks type, :update} and
          destroyed_children.all?{|obj| obj.run_all_callbacks type, :destroy}
      elsif method == :destroy
        child_objects.all? do |group|
          group.all? do |obj|
            obj.run_all_callbacks type, method
          end
        end
      else
        raise_error "unknown callback method (#{method})!"
      end

      if type == :after
        ::Mongo::Object.run_after_callbacks self, method
      else
        true
      end

      result
    end
end