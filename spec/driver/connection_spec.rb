require 'driver/spec_helper'

describe "Connection" do
  with_mongo

  it "should provide handy access to databases" do
    db.connection.some_db.name.should == 'some_db'
  end
end