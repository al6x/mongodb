require 'mongo_db/driver'

require 'ruby_ext'
require 'rspec_ext'
require 'mongo_db/driver/spec'

# 
# Handy spec helpers
# 
rspec do
  def db
    mongo.db
  end
end

Object.class_eval do
  def mongo_id?; false end
end
BSON::ObjectId.class_eval do
  def mongo_id?; true end
end