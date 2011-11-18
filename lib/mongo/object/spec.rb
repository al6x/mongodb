require 'mongo/object'
require 'mongo/driver/spec'

Mongo::Object.class_eval do
  # RSpec adds some instance variables and we need to skip it.
  def persistent_instance_variable_names
    instance_variables.select{|n| n !~ /^@_|^@mock_proxy/}
  end

  class << self
    # Disabling cache.
    def constantize class_name
      eval class_name, TOPLEVEL_BINDING, __FILE__, __LINE__
    end
  end
end