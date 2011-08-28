require 'mongodb/object'
require 'ruby_ext'
require 'i18n'

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
).each{|f| require "mongodb/model/#{f}"}

module Mongo
  module Model
    inherit Db, Assignment, Callbacks, Validation, Crud, Query, Scope, AttributeConvertors, Misc
  end
end