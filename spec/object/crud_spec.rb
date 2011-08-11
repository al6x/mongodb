require 'spec_helper'

describe "Object" do
  with_mongo_model
  
  describe 'simple' do
    before do
      class Person
        def initialize name, info; @name, @info = name, info end
        attr_accessor :name, :info
        def == o; [self.class, name, info] == [o.class, o.respond_to(:name), o.respond_to(:info)] end
      end
    
      @zeratul = User.new 'Zeratul', 'Dark Templar'
    end
    after{remove_constants :Person}
  
    it 'crud' do
      # read
      db.heroes.count.should == 0
      db.heroes.all.should == []
      db.heroes.first.should == nil
  
      # create
      db.heroes.save(@zeratul)
      @zeratul.instance_variable_get(:@_id).should be_present
    
      # read
      db.heroes.count.should == 1
      db.heroes.all.should == [@zeratul]
      db.heroes.first.should == @zeratul
      db.heroes.first.object_id.should_not == @zeratul.object_id
    
      # update
      @zeratul.info = 'Killer of Cerebrates'
      db.heroes.save @zeratul
      db.heroes.count.should == 1
      db.heroes.first(name: 'Zeratul').info.should == 'Killer of Cerebrates'
    
      # destroy
      db.heroes.destroy @zeratul
      db.heroes.count.should == 0
    end
  end
  
  describe 'embedded' do
    before do 
      class Player
        attr_accessor :missions
        def == o; [self.class, self.missions] = [o.class, o.respond_to(:missions)] end
        
        class Mission
          def initialize name, stats; @name, @stats = name, stats end
          attr_accessor :name, :stats
          def == o; [self.class, self.name, self.stats] = [o.class, o.respond_to(:name), o.respond_to(:stats)] end
        end                
      end
      
      @player = Player.new
      @player.missions = [
        Player::Mission.new('Wasteland',         {buildings: 5, units: 10}),
        Player::Mission.new('Backwater Station', {buildings: 8, units: 25}),
      ]
    end
    after{remove_constants :Player}
    
    it 'crud' do
      # create
      db.players.save(@player)
      @player.instance_variable_get(:@_id).should be_present

      # read
      db.players.count.should == 1
      db.players.first.should == @player

      # update
      @player.missions.first.stats[:units] = 9
      @player.missions << Player::Mission.new('Desperate Alliance', {buildings: 11, units: 40}),
      db.players.save @player
      db.players.count.should == 1
      db.players.first.should == @player
      db.players.first.object_id.should_not == @player.object_id

      # destroy
      db.players.destroy @player
      db.players.count.should == 0
    end
  end    
end