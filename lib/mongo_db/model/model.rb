module Mongo::Model
  attr_accessor :_id, :_class

  class << self
    attr_accessor :db, :connection
    attr_required :db, :connection
  end
end