require 'driver/spec_helper'

describe "Collection" do
  with_mongo

  it "should by default update all matched by criteria (not first as default in mongo)" do
    db.units.save name: 'Probe', race: 'Protoss', status: 'alive'
    db.units.save name: 'Zealot', race: 'Protoss', status: 'alive'

    # Update.
    db.units.update({race: 'Protoss'}, :$set => {status: 'dead'})
    db.units.all.collect{|u| u['status']}.should == %w(dead dead)

    # Delete.
    db.units.delete race: 'Protoss'
    db.units.count.should == 0
  end

  it "should return first element of collection" do
    db.units.first.should be_nil
    unit = {name: 'Zeratul'}
    db.units.save(unit).should be_mongo_id
    db.units.first(name: 'Zeratul')['name'].should == 'Zeratul'
  end

  it 'should return all elements of collection' do
    db.units.all.should == []

    unit = {name: 'Zeratul'}
    db.units.save(unit).should be_mongo_id

    list = db.units.all(name: 'Zeratul')
    list.size.should == 1
    list.first['name'].should == 'Zeratul'

    # With block.
    list = []; db.units.all{|o| list << o}
    list.size.should == 1
    list.first['name'].should == 'Zeratul'
  end

  it 'should return count of elements in collection' do
    db.units.count(name: 'Zeratul').should == 0
    db.units.save name: 'Zeratul'
    db.units.save name: 'Tassadar'
    db.units.count(name: 'Zeratul').should == 1
  end

  it "should rewrite underscore symbol to dollar in query" do
    db.units.save name: 'Jim',     age: 34
    db.units.save name: 'Zeratul', age: 600
    db.units.all(age: {_lt: 100}).count.should == 1
  end
end