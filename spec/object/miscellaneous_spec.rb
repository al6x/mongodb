require 'object/spec_helper'

describe "Miscellaneous" do
  with_mongo
  before_all do
    class Tmp
      include Mongo::Object
    end
  end
  after{remove_constants :Tmp}

  it "should use random string id (instead of default BSON::ObjectId)" do
    o = Tmp.new
    db.objects.save o
    o._id.should be_a(String)
    o._id.size.should == Mongo.defaults[:random_string_id_size]
  end
end