require 'mongodb/driver'

class Mongo::Migration; end

%w(
  definition
  migration
).each{|f| require "mongodb/migration/#{f}"}