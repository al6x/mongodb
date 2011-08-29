require 'mongodb/driver/spec'

# RSpec adds some instance variables and we need to skip it.
Mongo::ObjectSerializer.send :const_set, :SKIP_IV_REGEXP, /^@_|^@mock_proxy/
Mongo::ObjectSerializer::SIMPLE_TYPES << RSpec::Mocks::Proxy