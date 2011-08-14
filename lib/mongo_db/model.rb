require 'mongo_db/driver'

%w(
  model_helper
  collection
).each{|f| require "mongo_db/model/#{f}"}

# collection
Mongo::Collection.class_eval do
  %w(insert update remove).each do |method|
    alias_method "#{method}_without_model", method
    alias_method method, "#{method}_with_model"
  end
end