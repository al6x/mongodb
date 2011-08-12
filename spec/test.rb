require 'spec_helper'

db = Mongo::Connection.new("localhost").db("default_test")
p db.class
puts db.methods.sort