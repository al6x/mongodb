require 'spec_helper'
require 'object/crud_shared'

describe "Model CRUD" do
  with_mongo_model
  
  describe 'simple' do
    before do
      class Person
        inherit Mongo::Model
        collection{db.units}
        
        def initialize name, info; @name, @info = name, info end
        attr_accessor :name, :info
        def == o; [self.class, name, info] == [o.class, o.respond_to(:name), o.respond_to(:info)] end
      end
    
      @zeratul = User.new 'Zeratul', 'Dark Templar'
    end
    after{remove_constants :Person}
  
    it_should_behave_like "object CRUD"
    
    it 'model crud' do
      # read
      Person.count.should == 0
      Person.all.should == []
      Person.first.should == nil

      # create
      @zeratul.save.should be_true
      @zeratul._id.should be_present

      # read
      Person.count.should == 1
      Person.all.should == [@zeratul]
      Person.first.should == @zeratul
      Person.first.object_id.should_not == @zeratul.object_id
      
      # update
      @zeratul.info = 'Killer of Cerebrates'
      @zeratul.save.should be_true
      Person.count.should == 1
      Person.first(name: 'Zeratul').info.should == 'Killer of Cerebrates'

      # destroy
      @zeratul.destroy.should be_true
      Person.count.should == 0
    end
    
    it 'should be able to save to another collection' do
      # create
      @zeratul.save(collection: db.protosses).should be_true
      @zeratul._id.should be_present      

      # read
      Person.count.should == 0
      db.protosses.count.should == 1
      db.protosses.should == @zeratul
      db.protosses.object_id.should_not == @zeratul.object_id
      
      # update
      @zeratul.info = 'Killer of Cerebrates'
      @zeratul.save(collection: db.protosses).should be_true
      Person.count.should == 0
      db.protosses.count.should == 1
      db.protosses.first(name: 'Zeratul').info.should == 'Killer of Cerebrates'

      # destroy
      @zeratul.destroy(collection: db.protosses).should be_true
      db.protosses.count.should == 0
    end
  end
  
  describe 'embedded' do
    before do 
      class Player
        inherit Mongo::Model
        attr_accessor :missions
        def == o; [self.class, self.missions] = [o.class, o.respond_to(:missions)] end
        
        class Mission
          inherit Mongo::Model
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
    
    it_should_behave_like 'shared object CRUD'
    
    it 'crud' do
      # create
      @player.save.should be_true
      @player._id.should be_present

      # read
      Player.count.should == 1
      Player.first.should == @player
      Player.first.object_id.should_not == @players.object_id

      # update
      @player.missions.first.stats[:units] = 9
      @player.missions << Player::Mission.new('Desperate Alliance', {buildings: 11, units: 40}),
      @player.save.should be_true
      Player.count.should == 1
      Player.first.should == @player
      Player.first.object_id.should_not == @player.object_id

      # destroy
      @player.destroy.should be_true
      Player.count.should == 0
    end
  end    
end