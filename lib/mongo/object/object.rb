module Mongo::Object
  warn 'remove :_id?'
  attr_accessor :_id, :_parent

  def create_object collection, options
    doc = ::Mongo::Object.to_mongo self
    collection.create doc, options
    self._id = doc['_id']
  end

  def update_object collection, options
    id = _id || "can't update object without _id (#{self})!"
    doc = ::Mongo::Object.to_mongo self
    collection.update({_id: id}, doc, options)
  end

  def delete_object collection, options
    id = _id || "can't delete object without _id (#{self})!"
    collection.delete({_id: id}, options)
  end

  def save_object collection, options
    if _id
      update_object collection, options
    else
      create_object collection, options
    end
  end

  # Need this to allow to change it in specs,
  # RSpec adds @mock_proxy, and we need to skip it.
  SKIP_IV_REGEXP = /^@_/

  class << self

    warn 'move to instance methods'
    def each_instance_variable obj, &block
      instance_variables(obj).each do |iv_name|
        block.call iv_name, obj.instance_variable_get(iv_name)
      end
    end

    # Skipping variables starting with @_, usually they
    # have specific meaning and used for things like cache.
    def instance_variables obj
      obj.instance_variables.select{|n| n !~ SKIP_IV_REGEXP}
    end

    # Convert object to document (with nested documents & arrays).
    def to_mongo obj
      return obj.to_mongo if obj.respond_to? :to_mongo

      if obj.is_a? Hash
        {}.tap{|h| obj.each{|k, v| h[k] = to_mongo v}}
      elsif obj.is_a? Array
        obj.collect{|v| to_mongo v}
      elsif obj.is_a? Mongo::Object
        {}.tap do |doc|
          # Copy instance variables.
          each_instance_variable obj do |iv_name, v|
            k = iv_name.to_s[1..-1]
            doc[k] = to_mongo v
          end

          # Adding _id & _class.
          id = instance_variable_get('@_id')
          doc['_id']    = id if id
          doc['_class'] = obj.class.name
        end
      else
        # Simpe type.
        obj
      end
    end

    def build doc
      doc && _build(doc, nil)
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
            # TODO update it.
            # run_after_callbacks obj, :build
            obj
          else
            {}.tap{|h| doc.each{|k, v| h[k] = _build v, parent}}
          end
        elsif doc.is_a? Array
          doc.collect{|v| _build v, parent}
        else
          # Simple type.
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