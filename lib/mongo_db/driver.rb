require 'mongo_db/gems'

require 'mongo'

# namespace for extensions
class Mongo::Ext; end

# mongo extensions
Mongo.class_eval do
  def self.defaults; @defaults ||= {} end
end

%w(
  support
  database
  collection  
  hash_helper
).each{|f| require "mongo_db/driver/#{f}"}