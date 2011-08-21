require 'mongo_db/driver/core'

class Mongo::Error < StandardError; end
class Mongo::NotFound < Mongo::Error; end

%w(
  collection_finders
).each{|f| require "mongo_db/driver/more/#{f}"}

Mongo::Collection.send :include, Mongo::CollectionFinders

