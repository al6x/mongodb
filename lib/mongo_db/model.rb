begin
  require 'ruby_ext'
rescue LoadError => e
  warn 'Model requires the ruby_ext gem, please install it'
  raise e
end

require 'mongo_db/object'

module Mongo::Model; end

%w(
  db
  callbacks
  crud
  query
  scope
  model
).each{|f| require "mongo_db/model/#{f}"}

module Mongo
  module Model
    inherit Db, Callbacks, Crud, Query, Scope
  end
end