require 'object/spec_helper'
require 'mongo/object/spec/crud_shared'

describe "Object CRUD" do
  with_mongo

  describe 'single' do
    before do
      class Unit
        include Mongo::Object

        attr_accessor :name, :info
        def == o; [self.class, name, info] == [o.class, o.name, o.info] end
      end

      @zeratul = Unit.new.tap do |o|
        o.name, o.info = 'Zeratul', 'Dark Templar'
      end
    end
    after{remove_constants :Unit}

    it_should_behave_like "object CRUD"

    it "should allow to read object as hash, without unmarshalling" do
      db.units.save! @zeratul
      db.units.first({}, object: false).is_a?(Hash).should be_true
    end
  end

  describe 'embedded' do
    before do
      class Unit2
        include Mongo::Object

        attr_accessor :items
        def == o; [self.class, self.items] == [o.class, o.items] end

        class Item
          include Mongo::Object

          attr_accessor :name
          def == o; [self.class, self.name] == [o.class, o.name] end
        end
      end

      @item_class = Unit2::Item
      @zeratul = Unit2.new
      @zeratul.items = [
        Unit2::Item.new.tap{|o| o.name = 'Psionic blade'},
        Unit2::Item.new.tap{|o| o.name = 'Plasma shield'},
      ]
    end
    after{remove_constants :Unit2}

    it_should_behave_like 'embedded object CRUD'
  end
end