require 'mongo_db/gems'

require 'mongo'

%w(
  database
  collection
).each{|f| require "mongo_db/driver/core/#{f}"}

# defaults
Mongo.class_eval do
  class << self
    def defaults; @defaults ||= {} end
    attr_writer :defaults
  end
end

# database
Mongo::DB.send :include, Mongo::DBExt

# collection
Mongo::Collection.class_eval do
  include Mongo::CollectionExt

  %w(insert update remove save count).each do |method|
    alias_method "#{method}_without_ext", method
    alias_method method, "#{method}_with_ext"
  end
end