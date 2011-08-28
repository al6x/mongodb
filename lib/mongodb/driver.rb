require 'mongodb/gems'

require 'mongo'

class Mongo::Error < StandardError; end
class Mongo::NotFound < Mongo::Error; end

%w(
  database
  collection
  dynamic_finders
).each{|f| require "mongodb/driver/#{f}"}

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
  include Mongo::CollectionExt, Mongo::DynamicFinders

  %w(insert update remove save count).each do |method|
    alias_method "#{method}_without_ext", method
    alias_method method, "#{method}_with_ext"
  end
end