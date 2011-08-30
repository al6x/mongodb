require 'mongo/object'

require 'rspec_ext'
require 'mongo/object/spec'

require 'driver/spec_helper'

# To simplify callback expectations
module RSpec::CallbackHelper
  def run_callbacks type, method_name
    callback_method_name = :"#{type}_#{method_name}"
    respond_to?(callback_method_name) ? send(callback_method_name) : true
  end
end