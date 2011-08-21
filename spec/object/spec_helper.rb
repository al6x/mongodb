require 'mongo_db/object'
require 'driver/spec_helper'

# RSpec adds some instance variables and we need to skip it.
Mongo::ObjectSerializer.send :const_set, :SKIP_IV_REGEXP, /^@_|^@mock_proxy/
Mongo::ObjectSerializer::SIMPLE_TYPES << RSpec::Mocks::Proxy

# To simplify callback expectations
module RSpec::CallbackHelper
  def _run_callbacks type, method_name
    callback_method_name = :"#{type}_#{method_name}"
    send callback_method_name if respond_to? callback_method_name
  end
end