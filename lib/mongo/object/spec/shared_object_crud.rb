shared_examples_for 'single object CRUD' do
  it 'should convert object to mongo hash format' do
    expected = {
      "_class" => "Unit",
      "name"   => "Zeratul",
      "info"   => "Dark Templar"
    }
    @unit.to_mongo.should == expected

    @unit._id    = 'some id'
    expected['_id'] = 'some id'
    @unit.to_mongo.should == expected
  end

  it 'should perform CRUD' do
    # Read.
    db.units.count.should == 0
    db.units.all.should == []
    db.units.first.should == nil

    # Create.
    db.units.save(@unit).should be_true
    @unit._id.should_not be_nil

    # Read.
    db.units.count.should == 1
    obj = db.units.first
    obj.should == @unit
    obj.class.should == @unit.class
    obj.object_id.should_not == @unit.object_id

    # Update.
    @unit.info = 'Killer of Cerebrates'
    db.units.save(@unit).should be_true
    db.units.count.should == 1
    db.units.first(name: 'Zeratul').info.should == 'Killer of Cerebrates'

    # Delete.
    db.units.delete(@unit).should be_true
    db.units.count.should == 0
  end
end

shared_examples_for 'embedded object CRUD' do
  it 'should convert object to mongo hash format' do
    expected = {
      "_class" => "Unit",
      "items"  => [
        {"name" => "Psionic blade", "_class" => "Unit::Item"},
        {"name" => "Plasma shield", "_class" => "Unit::Item"}
      ]
    }
    @unit.to_mongo.should == expected

    @unit._id    = 'some id'
    expected['_id'] = 'some id'
    @unit.to_mongo.should == expected
  end

  it 'should perform CRUD' do
    # Create.
    db.units.save @unit
    @unit._id.should_not be_nil

    item = @unit.items.first
    item._id.should be_nil

    # Read.
    db.units.count.should == 1
    unit = db.units.first
    unit.should == @unit
    unit.object_id.should_not == @unit.object_id

    item = unit.items.first
    item._id.should be_nil

    # Update.
    @unit.items.first.name = 'Psionic blade level 3'
    item = @item_class.new.tap{|o| o.name = 'Power suit'}
    @unit.items << item
    db.units.save @unit
    db.units.count.should == 1
    unit = db.units.first
    unit.should == @unit
    unit.object_id.should_not == @unit.object_id

    # Delete.
    db.units.delete @unit
    db.units.count.should == 0
  end

  it "embedded object should have :_parent reference to the main object" do
    db.units.save @unit
    unit = db.units.first
    unit._parent.should be_nil
    unit.items.first._parent.should == unit
  end

  # Discarded.
  # describe "id for embedded objects" do
  #   old = nil
  #   before{old = Mongo.defaults[:generate_id]}
  #   after{Mongo.defaults[:generate_id] = old}
  #
  #   it "should not be generated if not specified" do
  #     Mongo.defaults[:generate_id] = false
  #
  #     db.units.save @unit
  #     unit = db.units.first
  #
  #     @unit.items.first._id.should be_nil
  #     unit.items.first._id.should be_nil
  #   end
  #
  #   it "should be generated if specified" do
  #     Mongo.defaults[:generate_id] = true
  #
  #     db.units.save @unit
  #     unit = db.units.first
  #
  #     @unit.items.first._id.should be_present
  #     unit.items.first._id.should be_present
  #   end
  # end
end