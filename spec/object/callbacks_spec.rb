require 'object/spec_helper'

describe 'Object callbacks' do
  with_mongo

  before :all do
    class Player
      include RSpec::CallbackHelper
      attr_accessor :missions

      class Mission
        include RSpec::CallbackHelper
      end
    end
  end
  after(:all){remove_constants :Player}

  before do
    @mission = Player::Mission.new
    @player = Player.new
    @player.missions = [@mission]
  end

  it 'create' do
    %w(before_validate before_save before_create after_create after_save after_validate).each do |name|
      @player.should_receive(name).once.ordered
      @mission.should_receive(name).once.ordered
    end

    db.players.save @player
  end

  it 'update' do
    db.players.save(@player)

    %w(before_validate before_save before_update after_update after_save after_validate).each do |name|
      @player.should_receive(name).once.ordered
      @mission.should_receive(name).once.ordered
    end
    db.players.save @player
  end

  it 'destroy' do
    db.players.save @player

    %w(before_validate before_destroy after_destroy after_validate).each do |name|
      @player.should_receive(name).once.ordered
      @mission.should_receive(name).once.ordered
    end
    db.players.destroy @player
  end

  it 'should be able skip callbacks' do
    @player.should_not_receive(:_run_callbacks)
    @mission.should_not_receive(:_run_callbacks)

    db.players.save @player, callbacks: false
    db.players.count.should == 1
    db.players.save @player, callbacks: false
    db.players.count.should == 1
    db.players.destroy @player, callbacks: false
    db.players.count.should == 0
  end

  it 'should be able interrupt CRUD' do
    @mission.stub! :_run_callbacks do |type, method_name|
      false if type == :before and method_name == :save
    end
    db.players.save(@player).should be_false
    db.players.count.should == 0
  end

  describe "embedded" do
    it 'should fire :destroy on detached objects' do
      db.players.save @player
      @player.missions.clear
      @mission.should_receive(:before_destroy).once
      db.players.destroy @player
    end

    it 'should fire :destroy on deleted objects in update' do
      db.players.save @player
      @player.missions.clear
      @mission.should_receive(:before_destroy).once
      db.players.save @player
    end

    it 'should fire :create on new objects in update' do
      db.players.save @player
      mission2 = Player::Mission.new
      @player.missions << mission2
      mission2.should_receive(:before_create).once
      mission2.should_not_receive(:before_update)
      db.players.save @player
    end
  end
end