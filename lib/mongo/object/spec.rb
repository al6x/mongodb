require 'mongo/object'
require 'mongo/driver/spec'

# RSpec adds some instance variables and we need to skip it.
Mongo::Object.class_eval do
  def persistent_instance_variables
    instance_variables.select{|n| n !~ /^@_|^@mock_proxy/}
  end
end