require 'spec_helper'

describe 'Object callbacks' do
  with_mongo_model
  
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
      :validate,
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
      :validate,
      :after_validation,
      :before_destroy,
      :after_destroy,
    ].each do |name|
      @player.should_receive(name).ordered
      @misson.should_receive(name).ordered
    end
    db.players.destroy @player
  end
  
  it 'should be able interrupt CRUD' do
    @misson.stub!(:before_save).and_return(false)
    db.players.save(@player).should be_false
    db.players.count.should == 0
  end
  
  it 'should be able skip callbacks' do
    [
      :before_validation,
      :after_validation,
      :before_save,
      :before_create,
      :after_create,
      :after_save,
      :before_update,
      :after_update,
      :before_destroy,
      :after_destroy
    ].each do |name|
      @player.should_not_receive(name)
      @misson.should_receive(name)
    end
    
    db.players.save @player, callbacks: false
    db.players.count.should == 1
    db.players.save @player, callbacks: false
    db.players.count.should == 1
    db.players.destroy @player, callbacks: false
    db.players.count.should == 0
  end
end