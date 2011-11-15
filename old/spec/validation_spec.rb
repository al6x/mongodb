require 'object/spec_helper'

describe 'Object validation' do
  with_mongo

  before_all do
    class Player
      include Mongo::Object

      attr_accessor :missions

      class Mission
        include Mongo::Object
      end
    end
  end
  after_all{remove_constants :Player}

  before do
    @mission = Player::Mission.new
    @player = Player.new
    @player.missions = [@mission]
  end

  it 'should not save/update/delete invalid objects' do
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

    # delete
    @player.stub!(:valid?).and_return(false)
    db.players.delete(@player).should be_false

    @player.stub!(:valid?).and_return(true)
    db.players.delete(@player).should be_true
  end

  it 'should not save/update/delete invalid embedded objects' do
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

    # delete
    @mission.stub!(:valid?).and_return(false)
    db.players.delete(@player).should be_false

    @mission.stub!(:valid?).and_return(true)
    db.players.delete(@player).should be_true
  end

  it "should be able skip validation" do
    @player.stub!(:valid?).and_return(false)
    db.players.save(@player, validate: false).should be_true

    @player.stub!(:valid?).and_return(true)
    @mission.stub!(:valid?).and_return(false)
    db.players.save(@player, validate: false).should be_true
  end
end