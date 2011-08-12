require 'mongo_db/driver'

%w(
).each{|f| require "mongo_db/model/#{f}"}