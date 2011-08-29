require 'mongo/driver'

class Mongo::Migration; end

%w(
  definition
  migration
).each{|f| require "mongo/migration/#{f}"}