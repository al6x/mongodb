require 'object/spec_helper'

describe 'Object callbacks' do
  with_mongo

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
    [:before_validate, :before_save, :before_create, :after_create, :after_save, :after_validate].each do |name|
      @player.should_receive(:run_callbacks).with(name).once.ordered
      @mission.should_receive(:run_callbacks).with(name).once.ordered
    end

    db.players.save @player
  end

  it 'update' do
    db.players.save(@player)

    [:before_validate, :before_save, :before_update, :after_update, :after_save, :after_validate].each do |name|
      @player.should_receive(:run_callbacks).with(name).once.ordered
      @mission.should_receive(:run_callbacks).with(name).once.ordered
    end
    db.players.save @player
  end

  it 'destroy' do
    db.players.save @player

    [:before_validate, :before_save, :before_destroy, :after_destroy, :after_save, :after_validate].each do |name|
      @player.should_receive(:run_callbacks).with(name).once.ordered
      @mission.should_receive(:run_callbacks).with(name).once.ordered
    end
    db.players.destroy @player
  end

  it 'should be able skip callbacks' do
    @player.should_not_receive(:run_callbacks)
    @mission.should_not_receive(:run_callbacks)

    db.players.save @player, callbacks: false
    db.players.count.should == 1
    db.players.save @player, callbacks: false
    db.players.count.should == 1
    db.players.destroy @player, callbacks: false
    db.players.count.should == 0
  end

  it 'should be able interrupt CRUD' do
    @mission.stub! :run_callbacks do |name|
      false if name == :before_save
    end
    db.players.save(@player).should be_false
    db.players.count.should == 0
  end

end