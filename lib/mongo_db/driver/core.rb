require 'mongo_db/gems'

require 'mongo'

# namespace for extensions
class Mongo::Ext; end

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
Mongo::DB.send :include, Mongo::Ext::DB

# collection
Mongo::Collection.class_eval do
  include Mongo::Ext::Collection

  %w(insert update remove save).each do |method|
    alias_method "#{method}_without_ext", method
    alias_method method, "#{method}_with_ext"
  end
end