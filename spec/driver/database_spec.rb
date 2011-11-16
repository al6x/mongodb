require 'driver/spec_helper'

describe "Database" do
  with_mongo

  it "should provide handy shortcuts to collections" do
    db.some_collection.name.should == 'some_collection'
  end
end