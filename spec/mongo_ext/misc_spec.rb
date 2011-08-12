require 'mongo_ext/spec_helper'

describe "Mongo Extensions" do
  with_mongo
  
  it "should provide handy access to collections" do
    mongo.db['collection1']
    mongo.db.collection1
  end
end