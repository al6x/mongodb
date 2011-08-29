require 'mongodb/object'

require 'mongodb/object/spec'
require 'driver/spec_helper'

# To simplify callback expectations
module RSpec::CallbackHelper
  def _run_callbacks type, method_name
    callback_method_name = :"#{type}_#{method_name}"
    send callback_method_name if respond_to? callback_method_name
  end
end