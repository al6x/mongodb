require 'mongodb/gems'

require 'mongo'

class Mongo::Error < StandardError; end
class Mongo::NotFound < Mongo::Error; end

%w(
  connection
  database
  collection
  dynamic_finders
).each{|f| require "mongo/driver/#{f}"}

Mongo.class_eval do
  class << self
    def defaults; @defaults ||= {} end
    attr_writer :defaults

    # Override this method to provide Your own custom database initialization logic.
    def db name
      name = name.to_s
      @databases ||= {}
      @databases[name] ||= begin
        connection = Mongo::Connection.new
        connection.db name
      end
    end
  end
end

Mongo::Connection.send :include, Mongo::ConnectionExt

Mongo::DB.send :include, Mongo::DBExt

Mongo::Collection.class_eval do
  include Mongo::CollectionExt, Mongo::DynamicFinders

  %w(insert update remove save count).each do |method|
    alias_method "#{method}_without_ext", method
    alias_method method, "#{method}_with_ext"
  end
end

Mongo.defaults[:convert_id_to_string] = true