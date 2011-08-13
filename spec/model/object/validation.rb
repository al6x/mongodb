require 'spec_helper'

describe 'Object validation' do
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

  it 'should not save/update/destroy invalid objects' do
    # create
    @player.stub!(:valid?).and_return(false)
    db.players.save(@player).should be_false

    @player.stub!(:valid?).and_return(true)
    db.players.save(@player).should be_true

    # update
    @player.stub!(:valid?).and_return(false)
    db.players.save(@player).should be_false

    @player.stub!(:valid?).and_return(true)
    db.players.save(@player).should be_true

    # destroy
    @player.stub!(:valid?).and_return(false)
    db.players.destroy(@player).should be_false

    @player.stub!(:valid?).and_return(true)
    db.players.destroy(@player).should be_true
  end

  it 'should not save/update/destroy invalid embedded objects' do
    # create
    @mission.stub!(:valid?).and_return(false)
    db.players.save(@player).should be_false

    @mission.stub!(:valid?).and_return(true)
    db.players.save(@player).should be_true

    # update
    @mission.stub!(:valid?).and_return(false)
    db.players.save(@player).should be_false

    @mission.stub!(:valid?).and_return(true)
    db.players.save(@player).should be_true

    # destroy
    @mission.stub!(:valid?).and_return(false)
    db.players.destroy(@player).should be_false

    @mission.stub!(:valid?).and_return(true)
    db.players.destroy(@player).should be_true
  end

  it "should be able skip validation" do
    @player.stub!(:valid?).and_return(false)
    db.players.save(@player, validate: false).should be_true

    @player.stub!(:valid?).and_return(true)
    @mission.stub!(:valid?).and_return(false)
    db.players.save(@player, validate: false).should be_true
  end
end