require 'mongo/driver'

class Mongo::Migration; end

%w(
  definition
  migration
  dsl
).each{|f| require "mongo/migration/#{f}"}