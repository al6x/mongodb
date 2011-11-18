require 'driver/spec_helper'
require 'mongo/migration'

describe "Migration" do
  with_mongo
  before do
    @migration = Mongo::Migration.new
    @migration.db = mongo.db
  end

  it "shouldn't update if versions are the same" do
    @migration.update(0).should be_false
  end

  it "should provide access to database" do
    @migration.add 1 do |m|
      m.up do |db|
        db.users.save name: 'Bob'
      end
    end
    @migration.update(1).should be_true
    db.users.count.should == 1
  end

  it "should increase db version" do
    @migration.current_version.should == 0

    check = mock
    @migration.add 1 do |m|
      m.up{check.up}
    end

    check.should_receive :up
    @migration.update(1).should be_true
    @migration.current_version.should == 1
  end

  it "should decrease db version" do
    check = mock
    @migration.add 1 do |m|
      m.up{check.up}
      m.down{check.down}
    end

    check.should_receive :up
    @migration.update(1).should be_true

    check.should_receive :down
    @migration.update(0).should be_true
    @migration.current_version.should == 0
  end

  it "should migrate to the highest version if version not explicitly specified" do
    @migration.add 1 do |m|
      m.up{}
    end
    @migration.add 2 do |m|
      m.up{}
    end
    @migration.update.should be_true
    @migration.current_version.should == 2
  end
end