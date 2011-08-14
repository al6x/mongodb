class Mongo::Ext::ModelSerializer
  def self.constantize class_name
    @classes_cache ||= {}
    unless klass = @classes_cache[class_name]
      klass = eval class_name, TOPLEVEL_BINDING, __FILE__, __LINE__
      @classes_cache[class_name] = klass
    end
    klass
  end
end