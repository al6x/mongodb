require 'mongo/driver'

Mongo.class_eval do
  autoload :Object, 'mongo/object/load'
end