require 'object/spec_helper'

describe "Miscellaneous" do
  with_mongo
  old = Mongo.defaults[:generate_id] = false
  before do
    Mongo.defaults[:generate_id] = true
    class Tmp
      include Mongo::Object
    end
  end
  after do
    Mongo.defaults[:generate_id] = old
    remove_constants :Tmp
  end

  it "should use autogenerated random string id (if specified, instead of default BSON::ObjectId)" do
    o = Tmp.new
    db.objects.save o
    o._id.should be_a(String)
    o._id.size.should == Mongo.defaults[:random_string_id_size]
  end

  it "shoud convert to hash" do
    class Tmp
      attr_accessor :name
    end
    o = Tmp.new
    o.name = 'some name'
    o.to_hash.should == {name: 'some name', _class: 'Tmp'}
  end
end