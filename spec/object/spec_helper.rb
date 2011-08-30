require 'mongo/object'

require 'rspec_ext'
require 'mongo/object/spec'

require 'driver/spec_helper'

# To simplify callback expectations
module RSpec::CallbackHelper
  def run_before_callbacks method_name, opts = {}
    callback_method_name = :"before_#{method_name}"
    respond_to?(callback_method_name) ? send(callback_method_name) : true
  end

  def run_after_callbacks method_name, opts = {}
    callback_method_name = :"after_#{method_name}"
    respond_to?(callback_method_name) ? send(callback_method_name) : true
  end
end