require 'spec_helper'

describe 'Callbacks' do
  with_mongo_model
  
  describe 'object' do
    before do
      class Player
        attr_accessor :missions
              
        class Mission
        end                
      end
    
      @mission = Player::Mission.new
      @player = Player.new
      @player.missions = [@mission]
    end
    after{remove_constants :Player}
  
    it 'create' do
      [
        :before_validation,
        :after_validation,
        :before_save,
        :before_create,
        :after_create,
        :after_save
      ].each do |name|
        @player.should_receive(name).ordered
        @misson.should_receive(name).ordered
      end
      
      db.players.save @player
    end
    
    it 'update' do
      db.players.save @player
      
      [
        :before_validation,
        :after_validation,
        :before_save,
        :before_update,
        :after_update,
        :after_save
      ].each do |name|
        @player.should_receive(name).ordered
        @misson.should_receive(name).ordered
      end
      db.players.save @player
    end
    
    it 'destroy' do
      db.players.save @player
      
      [
        :before_validation,
        :after_validation,
        :before_destroy,
        :after_destroy,
      ].each do |name|
        @player.should_receive(name).ordered
        @misson.should_receive(name).ordered
      end
      db.players.destroy @player
    end
    
    it 'interruption' do
      @misson.stub!(:before_save).and_return(false)
      db.players.save(@player).should be_false
      db.player.count.should == 0
    end
  end
end