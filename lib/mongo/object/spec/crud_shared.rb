shared_examples_for 'single object CRUD' do
  it 'should perform CRUD' do
    # Read.
    db.units.count.should == 0
    db.units.all.should == []
    db.units.first.should == nil

    # Create.
    db.units.save(@zeratul).should be_true
    @zeratul._id.should_not be_nil

    # Read.
    db.units.count.should == 1
    obj = db.units.first
    obj.should == @zeratul
    obj.class.should == @zeratul.class
    obj.object_id.should_not == @zeratul.object_id

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
  it 'should perform CRUD' do
    # Create.
    db.units.save @zeratul
    @zeratul._id.should_not be_nil

    # Read.
    db.units.count.should == 1
    db.units.first.should == @zeratul
    db.units.first.object_id.should_not == @unit.object_id

    # Update.
    @zeratul.items.first.name = 'Plasma shield level 3'
    item = @item_class.new.tap{|o| o.name = 'Power suit'}
    @zeratul.items << item
    db.units.save @zeratul
    db.units.count.should == 1
    db.units.first.should == @zeratul
    db.units.first.object_id.should_not == @zeratul.object_id

    # Delete.
    db.units.delete @zeratul
    db.units.count.should == 0
  end

  it "embedded object should have :_parent reference to the main object" do
    db.units.save @zeratul
    zeratul = db.units.first
    zeratul.items.first._parent.should == zeratul
  end

  # describe "id for embedded objects" do
  #   old = nil
  #   before{old = Mongo.defaults[:generate_id]}
  #   after{Mongo.defaults[:generate_id] = old}
  #
  #   it "should not be generated if not specified" do
  #     Mongo.defaults[:generate_id] = false
  #
  #     db.units.save @zeratul
  #     zeratul = db.units.first
  #
  #     @zeratul.items.first._id.should be_nil
  #     zeratul.items.first._id.should be_nil
  #   end
  #
  #   it "should be generated if specified" do
  #     Mongo.defaults[:generate_id] = true
  #
  #     db.units.save @zeratul
  #     zeratul = db.units.first
  #
  #     @zeratul.items.first._id.should be_present
  #     zeratul.items.first._id.should be_present
  #   end
  # end
end