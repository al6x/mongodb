require 'mongo/driver'

%w(
  object_serializer
  object_helper
).each{|f| require "mongo/object/#{f}"}

Mongo.defaults[:callbacks] = true

# collection
Mongo::Collection.class_eval do
  include Mongo::ObjectHelper

  %w(insert update remove save).each do |method|
    alias_method "#{method}_without_object", method
    alias_method method, "#{method}_with_object"
  end
end