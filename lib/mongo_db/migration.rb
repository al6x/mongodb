require 'mongo_db/driver'

class Mongo::Migration; end

%w(
  definition
  migration
).each{|f| require "mongo_db/migration/#{f}"}