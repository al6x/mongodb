require 'mongo_db/driver/core'

class Mongo::NotFound < StandardError; end

%w(
  collection
).each{|f| require "mongo_db/driver/more/#{f}"}

Mongo.defaults.merge! \
  symbolize:   true,
  batch_size:  50,
  multi:       true,
  safe:        true