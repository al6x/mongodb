require 'mongo'

%w(
  database
).each{|f| require "mongo_model/support/#{f}"}