require 'driver/spec_helper'

describe "Hash CRUD" do
  with_mongo

  describe 'single' do
    before do
      @zeratul = {'name' => 'Zeratul', 'info' => 'Dark Templar'}
    end

    it 'should perform CRUD' do
      # Read.
      db.units.count.should == 0
      db.units.all.should == []
      db.units.first.should == nil

      # Create.
      db.units.save(@zeratul).should be_mongo_id
      @zeratul['_id'].should be_mongo_id

      # Read.
      db.units.all.should == [@zeratul]
      db.units.count.should == 1
      db.units.first.should == @zeratul

      # Update.
      @zeratul['info'] = 'Killer of Cerebrates'
      db.units.save @zeratul
      db.units.count.should == 1
      db.units.first(name: 'Zeratul')['info'].should == 'Killer of Cerebrates'

      # Delete.
      db.units.delete @zeratul
      db.units.count.should == 0
    end
  end

  describe 'embedded' do
    before do
      @zeratul = {
        'items' => [
          {'name' => 'Psionic blade'},
          {'name' => 'Plasma shield'}
        ]
      }
    end

    it 'should perform CRUD' do
      # Create.
      db.units.save(@zeratul).should be_mongo_id

      # Read.
      db.units.count.should == 1
      db.units.first.should == @zeratul

      # Update.
      @zeratul['items'].first['name'] = 'Plasma shield level 3'
      @zeratul['items'].push 'name' => 'Power suit'
      db.units.save(@zeratul).should_not be_nil
      db.units.count.should == 1
      db.units.first.should == @zeratul
      db.units.first.object_id.should_not == @zeratul.object_id

      # Delete.
      db.units.delete @zeratul
      db.units.count.should == 0
    end
  end
end