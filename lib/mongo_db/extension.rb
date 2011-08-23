require 'mongo_db/model'

Mongo::Model.class_eval do
  autoload :AttributeConvertors, "mongo_db/extension/attribute_convertors"
end

Mongo.class_eval do
  autoload :ExtModel, "mongo_db/extension/ext_model"
end