require 'driver/spec_helper'

describe "Connection" do
  with_mongo

  it "should provide handy shortcuts to databases" do
    db.connection.some_db.name.should == 'some_db'
  end
end