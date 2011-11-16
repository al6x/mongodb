require 'driver/spec_helper'

describe "Fixes" do
  with_mongo

  it "should always return array if input is array" do
    db.units.insert([{name: 'Zeratul'}]).class.should == Array

    db.units.insert(name: 'Zeratul').should be_mongo_id
    db.units.insert([{name: 'Zeratul'}, {name: 'Tassadar'}]).class.should == Array
  end
end