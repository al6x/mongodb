require 'object/spec_helper'

describe 'Object callbacks' do
  with_mongo

  before :all do
    class Player
      include Mongo::Object, RSpec::CallbackHelper
      attr_accessor :missions

      class Mission
        include Mongo::Object, RSpec::CallbackHelper
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
    %w(before_validate after_validate before_create after_create).each do |name|
      @player.should_receive(name).once.ordered.and_return(true)
      @mission.should_receive(name).once.ordered.and_return(true)
    end

    db.players.save(@player).should be_true
  end

  it 'update' do
    db.players.save(@player).should be_true

    %w(before_validate after_validate before_update after_update).each do |name|
      @player.should_receive(name).once.ordered.and_return(true)
      @mission.should_receive(name).once.ordered.and_return(true)
    end
    db.players.save(@player).should be_true
  end

  it 'destroy' do
    db.players.save(@player).should be_true

    %w(before_validate after_validate before_destroy after_destroy).each do |name|
      @player.should_receive(name).once.ordered.and_return(true)
      @mission.should_receive(name).once.ordered.and_return(true)
    end
    db.players.destroy(@player).should be_true
  end

  it 'should be able skip callbacks' do
    @player.should_not_receive(:run_callbacks)
    @mission.should_not_receive(:run_callbacks)

    db.players.save(@player, callbacks: false).should be_true
    db.players.count.should == 1
    db.players.save(@player, callbacks: false).should be_true
    db.players.count.should == 1
    db.players.destroy(@player, callbacks: false).should be_true
    db.players.count.should == 0
  end

  it 'should be able interrupt CRUD' do
    @mission.stub! :run_callbacks do |type, method_name|
      false if type == :before and method_name == :create
    end
    db.players.save(@player).should be_false
    db.players.count.should == 0
  end

  describe "embedded" do
    it 'should fire :destroy on detached objects' do
      db.players.save(@player).should be_true
      @player.missions.clear
      @mission.should_receive(:before_destroy).once.and_return(true)
      db.players.destroy(@player).should be_true
    end

    it 'should fire :destroy on deleted objects in update' do
      db.players.save(@player).should be_true
      @player.missions.clear
      @mission.should_receive(:before_destroy).once.and_return(true)
      db.players.save(@player).should be_true
    end

    it 'should fire :create on new objects in update' do
      db.players.save(@player).should be_true
      mission2 = Player::Mission.new
      @player.missions << mission2
      mission2.should_receive(:before_create).once.and_return(true)
      mission2.should_not_receive(:before_update)
      db.players.save(@player).should be_true
    end
  end
end