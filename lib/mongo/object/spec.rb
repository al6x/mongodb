require 'mongo/object'
require 'mongo/driver/spec'

# RSpec adds some instance variables and we need to skip it.
Mongo::Object.send :remove_const, :SKIP_IV_REGEXP
Mongo::Object.send :const_set, :SKIP_IV_REGEXP, /^@_|^@mock_proxy/