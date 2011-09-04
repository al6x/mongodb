require 'mongo/driver'

Mongo.defaults.merge! \
  convert_underscore_to_dollar: true,
  batch_size:                   50,
  multi:                        true,
  safe:                         true

require 'ruby_ext'
require 'rspec_ext'
require 'mongo/driver/spec'

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