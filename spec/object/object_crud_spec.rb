require 'object/spec_helper'
require 'mongo/object/spec/shared_object_crud'

describe "Object CRUD" do
  with_mongo

  describe 'single object' do
    it_should_behave_like "single object CRUD"

    before do
      class Unit
        include Mongo::Object

        attr_accessor :name, :info
        def == o; [self.class, name, info] == [o.class, o.name, o.info] end
      end

      @unit = Unit.new.tap do |o|
        o.name, o.info = 'Zeratul', 'Dark Templar'
      end
    end
    after{remove_constants :Unit}

    it "should allow to read object as hash, without unmarshalling" do
      db.units.save! @unit
      db.units.first({}, object: false).is_a?(Hash).should be_true
    end
  end

  describe 'embedded object' do
    it_should_behave_like 'embedded object CRUD'

    before do
      class Unit
        include Mongo::Object

        attr_accessor :items
        def == o; [self.class, self.items] == [o.class, o.items] end

        class Item
          include Mongo::Object

          attr_accessor :name
          def == o; (self.class == o.class) and (self.name == o.name) end
        end
      end

      @item_class = Unit::Item
      @unit = Unit.new
      @unit.items = [
        Unit::Item.new.tap{|o| o.name = 'Psionic blade'},
        Unit::Item.new.tap{|o| o.name = 'Plasma shield'},
      ]
    end
    after{remove_constants :Unit}
  end
end