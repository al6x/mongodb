shared_examples_for 'object CRUD' do
  it 'crud' do
    # Read.
    db.units.count.should == 0
    db.units.all.should == []
    db.units.first.should == nil

    # Create.
    db.units.save(@zeratul).should be_true
    @zeratul._id.should_not be_nil

    # Read.
    db.units.count.should == 1
    db.units.all.should == [@zeratul]
    db.units.first.should == @zeratul
    db.units.first.object_id.should_not == @zeratul.object_id

    # Update.
    @zeratul.info = 'Killer of Cerebrates'
    db.units.save(@zeratul).should be_true
    db.units.count.should == 1
    db.units.first(name: 'Zeratul').info.should == 'Killer of Cerebrates'

    # Delete.
    db.units.delete(@zeratul).should be_true
    db.units.count.should == 0
  end
end

shared_examples_for 'embedded object CRUD' do
  it 'crud' do
    # Create.
    db.players.save(@player)
    @player._id.should_not be_nil

    # Read.
    db.players.count.should == 1
    db.players.first.should == @player
    db.players.first.object_id.should_not == @players.object_id

    # Update.
    @player.missions.first.stats['units'] = 9
    mission = @mission_class.new.tap do |m|
      m.name = 'Desperate Alliance'
      m.stats = {'buildings' => 11, 'units' => 40}
    end
    @player.missions << mission
    db.players.save @player
    db.players.count.should == 1
    db.players.first.should == @player
    db.players.first.object_id.should_not == @player.object_id

    # Delete.
    db.players.delete @player
    db.players.count.should == 0
  end

  it "embedded object should have :_parent reference to the main object" do
    db.players.save @player
    player = db.players.first
    player.missions.first._parent.should == player
  end
end