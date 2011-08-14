require 'mongo_db/driver/core'

class Mongo::NotFound < StandardError; end

%w(
  hash_finders
).each{|f| require "mongo_db/driver/more/#{f}"}

Mongo::Collection.send :include, Mongo::Ext::HashFinders

