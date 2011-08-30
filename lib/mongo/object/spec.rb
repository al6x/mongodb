require 'mongo/driver/spec'

# RSpec adds some instance variables and we need to skip it.
Mongo::Object.send :const_set, :SKIP_IV_REGEXP, /^@_|^@mock_proxy/