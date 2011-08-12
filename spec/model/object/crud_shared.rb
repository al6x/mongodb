shared_examples_for 'object CRUD' do  
  it 'crud' do
    # read
    db.heroes.count.should == 0
    db.heroes.all.should == []
    db.heroes.first.should == nil

    # create
    db.heroes.save(@zeratul).should be_true
    @zeratul.instance_variable_get(:@_id).should be_present
  
    # read
    db.heroes.count.should == 1
    db.heroes.all.should == [@zeratul]
    db.heroes.first.should == @zeratul
    db.heroes.first.object_id.should_not == @zeratul.object_id
  
    # update
    @zeratul.info = 'Killer of Cerebrates'
    db.heroes.save(@zeratul).should be_true
    db.heroes.count.should == 1
    db.heroes.first(name: 'Zeratul').info.should == 'Killer of Cerebrates'
  
    # destroy
    db.heroes.destroy(@zeratul).should be_true
    db.heroes.count.should == 0
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