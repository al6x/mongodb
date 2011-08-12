require 'driver/spec_helper'

describe "Collection" do
  with_mongo
  
  it 'by default save must update all matched by criteria (not first as defautl in mongo)' do
    db.units.save name: 'Probe', race: 'Protoss', status: 'alive'
    db.units.save name: 'Zealot', race: 'Protoss', status: 'alive'

    # update
    db.units.update({race: 'Protoss'}, :$set => {status: 'dead'})
    db.units.all.collect{|u| u[:status]}.should == %w(dead dead)
    
    # destroy
    db.units.destroy race: 'Protoss'
    db.units.count.should == 0
  end
  
  describe "symbolize" do
    it 'should always return symbolized hashes' do
      zeratul = {name: 'Zeratul'}
      db.heroes.save(zeratul).should be_mongo_id
      r = db.heroes.first(name: 'Zeratul')
      r[:_id].should be_mongo_id
      r['_id'].should be_nil
      r[:name].should == 'Zeratul'
      r['name'].should be_nil
    end
    
    it "should be able to disable symbolization" do
      old = Mongo.defaults[:symbolize]
      begin
        Mongo.defaults[:symbolize] = false
      
        zeratul = {name: 'Zeratul'}
        db.heroes.save(zeratul).should be_mongo_id
        r = db.heroes.first(name: 'Zeratul')
        r[:_id].should be_nil
        r['_id'].should be_mongo_id
        r[:name].should be_nil
        r['name'].should == 'Zeratul'
      ensure
        Mongo.defaults[:symbolize] = old
      end
    end
  end
  
  it "first" do
    db.heroes.first.should be_nil
    zeratul = {name: 'Zeratul'}
    db.heroes.save(zeratul).should be_mongo_id
    db.heroes.first(name: 'Zeratul')[:name].should == 'Zeratul'
  end
  
  it 'all' do
    db.heroes.all.should == []    
    
    zeratul = {name: 'Zeratul'}
    db.heroes.save(zeratul).should be_mongo_id
    
    list = db.heroes.all(name: 'Zeratul')
    list.size.should == 1
    list.first[:name].should == 'Zeratul'
    
    # with block
    list = []; db.heroes.all{|o| list << o}
    list.size.should == 1
    list.first[:name].should == 'Zeratul'
  end
end