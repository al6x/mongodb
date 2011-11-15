require 'mongo/driver'

Mongo.class_eval do
  autoload :Object, 'mongo/object/object'
end
require 'mongo/object/object_helper'

Mongo.defaults[:callbacks] = true

Mongo::Collection.class_eval do
  include Mongo::ObjectHelper

  %w(create update save delete).each do |method|
    alias_method "#{method}_without_object", method
    alias_method method, "#{method}_with_object"
  end
end