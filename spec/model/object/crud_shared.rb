shared_examples_for 'object CRUD' do  
  it 'crud' do
    # read
    db.units.count.should == 0
    db.units.all.should == []
    db.units.first.should == nil

    # create
    db.units.save(@zeratul).should be_true
    @zeratul.instance_variable_get(:@_id).should be_present
  
    # read
    db.units.count.should == 1
    db.units.all.should == [@zeratul]
    db.units.first.should == @zeratul
    db.units.first.object_id.should_not == @zeratul.object_id
  
    # update
    @zeratul.info = 'Killer of Cerebrates'
    db.units.save(@zeratul).should be_true
    db.units.count.should == 1
    db.units.first(name: 'Zeratul').info.should == 'Killer of Cerebrates'
  
    # destroy
    db.units.destroy(@zeratul).should be_true
    db.units.count.should == 0
  end
end

shared_examples_for 'embedded object CRUD' do  
  it 'crud' do
    # create
    db.players.save(@player)
    @player.instance_variable_get(:@_id).should be_present

    # read
    db.players.count.should == 1
    db.players.first.should == @player
    db.players.first.object_id.should_not == @players.object_id

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