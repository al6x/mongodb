require 'driver/spec_helper'

describe "Hash CRUD" do
  with_mongo

  describe 'single hash' do
    before do
      @unit = {'name' => 'Zeratul', 'info' => 'Dark Templar'}
    end

    it 'should perform CRUD' do
      # Read.
      db.units.count.should == 0
      db.units.all.should == []
      db.units.first.should == nil

      # Create.
      db.units.save(@unit).should be_mongo_id
      @unit['_id'].should be_mongo_id

      # Read.
      db.units.all.should == [@unit]
      db.units.count.should == 1
      db.units.first.should == @unit

      # Update.
      @unit['info'] = 'Killer of Cerebrates'
      db.units.save @unit
      db.units.count.should == 1
      db.units.first(name: 'Zeratul')['info'].should == 'Killer of Cerebrates'

      # Delete.
      db.units.delete @unit
      db.units.count.should == 0
    end
  end

  describe 'embedded hash' do
    before do
      @unit = {
        'items' => [
          {'name' => 'Psionic blade'},
          {'name' => 'Plasma shield'}
        ]
      }
    end

    it 'should perform CRUD' do
      # Create.
      db.units.save(@unit).should be_mongo_id

      # Read.
      db.units.count.should == 1
      db.units.first.should == @unit

      # Update.
      @unit['items'].first['name'] = 'Psionic blade level 3'
      @unit['items'].push 'name' => 'Power suit'
      db.units.save(@unit).should_not be_nil
      db.units.count.should == 1
      db.units.first.should == @unit
      db.units.first.object_id.should_not == @unit.object_id

      # Delete.
      db.units.delete @unit
      db.units.count.should == 0
    end
  end
end