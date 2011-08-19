require 'mongo_db/driver/core'

class Mongo::Migration; end

%w(
  definition
  migration
).each{|f| require "mongo_db/migration/#{f}"}