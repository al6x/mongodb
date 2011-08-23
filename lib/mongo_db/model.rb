begin
  require 'ruby_ext'
rescue LoadError => e
  warn 'Model requires the ruby_ext gem, please install it'
  raise e
end

require 'mongo_db/object'

module Mongo::Model; end

%w(
  support/types

  db
  assignment
  callbacks
  validation
  crud
  query
  scope
  attribute_convertors
  misc
  model
).each{|f| require "mongo_db/model/#{f}"}

module Mongo
  module Model
    inherit Db, Assignment, Callbacks, Validation, Crud, Query, Scope, AttributeConvertors, Misc
  end
end