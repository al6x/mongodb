require 'mongo_db/driver'

%w(
  model_serializer
  model_helper
).each{|f| require "mongo_db/model/#{f}"}

# collection
Mongo::Collection.class_eval do
  include Mongo::Ext::ModelHelper
  
  %w(insert update remove save).each do |method|
    alias_method "#{method}_without_model", method
    alias_method method, "#{method}_with_model"
  end
end