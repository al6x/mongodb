require 'driver/spec_helper'

describe "Hash CRUD" do
  with_mongo

  describe 'simple' do
    before do
      @zeratul = {name: 'Zeratul', info: 'Dark Templar'}
    end

    it 'crud' do
      # read
      db.units.count.should == 0
      db.units.all.should == []
      db.units.first.should == nil

      # create
      db.units.save(@zeratul).should be_mongo_id
      @zeratul[:_id].should be_mongo_id

      # read
      db.units.all.should == [@zeratul]
      db.units.count.should == 1
      db.units.first.should == @zeratul

      # update
      @zeratul[:info] = 'Killer of Cerebrates'
      db.units.save @zeratul
      db.units.count.should == 1
      db.units.first(name: 'Zeratul')[:info].should == 'Killer of Cerebrates'

      # destroy
      db.units.destroy @zeratul
      db.units.count.should == 0
    end
  end

  describe 'embedded' do
    before do
      @player = {
        name: 'Alex',
        missions: [
          {name: 'Wasteland',         stats: {buildings: 5, units: 10}},
          {name: 'Backwater Station', stats: {buildings: 8, units: 25}}
        ]
      }
    end

    it 'crud' do
      # create
      db.players.save(@player).should be_mongo_id

      # read
      db.players.count.should == 1
      db.players.first.should == @player

      # update
      @player[:missions].first[:stats][:units] = 9
      @player[:missions].push name: 'Desperate Alliance', stats: {buildings: 11, units: 40}
      db.players.save(@player).should_not be_nil
      db.players.count.should == 1
      db.players.first.should == @player
      db.players.first.object_id.should_not == @player.object_id

      # destroy
      db.players.destroy @player
      db.players.count.should == 0
    end
  end
end