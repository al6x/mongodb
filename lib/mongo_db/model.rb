begin
  require 'active_model'
rescue LoadError => e
  warn 'Model requires the active_model gem, please install it'
  raise e
end

begin
  require 'ruby_ext'
rescue LoadError => e
  warn 'Model requires the ruby_ext gem, please install it'
  raise e
end

require 'mongo_db/object'

module Mongo::Model; end

%w(
  model
).each{|f| require "mongo_db/model/#{f}"}