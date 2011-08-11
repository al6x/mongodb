require 'spec_helper'

describe "Object" do
  with_mongo_model
  
  describe 'simple' do
    before do
      @zeratul = {name: 'Zeratul', info: 'Dark Templar'}
    end
  
    it 'crud' do
      # read
      db.heroes.count.should == 0
      db.heroes.all.should == []
      db.heroes.first.should == nil
  
      # create
      db.heroes.save(@zeratul)
    
      # read
      db.heroes.all.should == [@zeratul]
      db.heroes.count.should == 1
      db.heroes.first.should == @zeratul
    
      # update
      @zeratul[:info] = 'Killer of Cerebrates'
      db.heroes.save({name: 'Zeratul'}, @zeratul)
      db.heroes.count.should == 1
      db.heroes.first(name: 'Zeratul').info.should == 'Killer of Cerebrates'
    
      # destroy
      db.heroes.destroy name: 'Zeratul'
      db.heroes.count.should == 0
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
      db.players.save(@player)

      # read
      db.players.count.should == 1
      db.players.first.should == @player

      # update
      @player[:missions].first[:stats][:units] = 9
      @player.missions << {name: 'Desperate Alliance', stats: {buildings: 11, units: 40}},
      db.players.save({name: 'Alex'}, @player)
      db.players.count.should == 1
      db.players.first.should == @player
      db.players.first.object_id.should_not == @player.object_id

      # destroy
      db.players.destroy name: 'Alex'
      db.players.count.should == 0
    end
  end  
end