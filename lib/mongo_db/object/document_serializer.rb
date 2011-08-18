class Mongo::DocumentSerializer
  attr_reader :doc
  
  def initialize doc
    @doc = doc
  end
  
  def to_object
    _to_object doc
  end
  
  def self.constantize class_name
    @constantize_cache ||= {}
    unless klass = @constantize_cache[class_name]
      klass = eval class_name, TOPLEVEL_BINDING, __FILE__, __LINE__
      @constantize_cache[class_name] = klass
    end
    klass
  end

  protected
    def _to_object doc
      if doc.is_a? Hash
        if class_name = doc[:_class] || doc['_class']
          klass = Mongo::DocumentSerializer.constantize class_name
          
          if klass.respond_to? :to_object
            klass.to_object doc
          else
            obj = klass.new
            doc.each do |k, v|
              next if k.to_sym == :_class

              v = _to_object v
              obj.instance_variable_set "@#{k}", v
            end
            obj
          end
        else
          doc
        end
      elsif doc.is_a? Array
        doc.collect{|v| _to_object v}
      else
        doc
      end
    end
end