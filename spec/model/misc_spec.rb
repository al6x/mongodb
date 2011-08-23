require 'model/spec_helper'

describe 'Model Miscellaneous' do
  with_mongo_model

  after{remove_constants :Unit3}

  it "timestamps" do
    class Unit3
      inherit Mongo::Model
      collection :units

      attr_accessor :name

      timestamps!
    end

    unit = Unit3.build name: 'Zeratul'
    unit.save!

    unit = Unit3.first
    unit.created_at.should_not be_nil
    unit.updated_at.should_not be_nil
    created_at,updated_at = unit.created_at, unit.updated_at

    unit.save!
    unit.created_at.should == created_at
    unit.updated_at.should >  updated_at
  end

  it 'cache' do
    class Unit3
      inherit Mongo::Model
    end
    u = Unit3.new
    u._cache.should == {}
  end
end