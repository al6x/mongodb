require 'driver/spec_helper'
require 'mongo/migration'

describe "Migration" do
  with_mongo
  before{@migration = Mongo::Migration.new mongo.db}

  it "shouldn't update if versions are the same" do
    @migration.update(0).should be_false
  end

  it "migration should provide access to database" do
    @migration.add 1 do |m|
      m.up do |db|
        db.users.save name: 'Bob'
      end
    end
    @migration.update(1).should be_true
    db.users.count.should == 1
  end

  it "increase_db_version" do
    @migration.current_version.should == 0

    check = mock
    @migration.add 1 do |m|
      m.up{check.up}
    end

    check.should_receive :up
    @migration.update(1).should be_true
    @migration.current_version.should == 1
  end

  it "decrease_db_version" do
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

  it "should automigrate to highest version" do
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