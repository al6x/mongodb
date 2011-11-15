require 'object/spec_helper'

describe 'Object callbacks' do
  with_mongo

  [Object, Array, Hash].each do |embedded_object_superclass|
    embedded_object_class = nil
    before :all do
      class MainObject
        include Mongo::Object, RSpec::CallbackHelper

        attr_accessor :children
      end

      embedded_object_class = Class.new embedded_object_superclass do
        include Mongo::Object, RSpec::CallbackHelper
      end
    end
    after(:all){remove_constants :MainObject}

    before do
      @child = embedded_object_class.new
      @object = MainObject.new
      @object.children = [@child]
    end

    it 'create' do
      %w(before_validate after_validate before_save before_create after_create after_save).each do |name|
        @object.should_receive(name).once.ordered.and_return(true)
        @child.should_receive(name).once.ordered.and_return(true)
      end

      db.objects.save(@object).should be_true
    end

    it 'update' do
      db.objects.save(@object).should be_true

      %w(before_validate after_validate before_save before_update after_update after_save).each do |name|
        @object.should_receive(name).once.ordered.and_return(true)
        @child.should_receive(name).once.ordered.and_return(true)
      end
      db.objects.save(@object).should be_true
    end

    it 'delete' do
      db.objects.save(@object).should be_true

      %w(before_validate after_validate before_delete after_delete).each do |name|
        @object.should_receive(name).once.ordered.and_return(true)
        @child.should_receive(name).once.ordered.and_return(true)
      end
      db.objects.delete(@object).should be_true
    end

    it 'should be able skip callbacks' do
      @object.should_not_receive(:run_callbacks)
      @child.should_not_receive(:run_callbacks)

      db.objects.save(@object, callbacks: false).should be_true
      db.objects.count.should == 1
      db.objects.save(@object, callbacks: false).should be_true
      db.objects.count.should == 1
      db.objects.delete(@object, callbacks: false).should be_true
      db.objects.count.should == 0
    end

    it 'should be able interrupt CRUD' do
      @child.stub! :run_before_callbacks do |method_name|
        false if method_name == :create
      end
      db.objects.save(@object).should be_false
      db.objects.count.should == 0
    end

    describe "embedded" do
      it 'should fire :delete on detached objects' do
        db.objects.save(@object).should be_true
        @object.children.clear
        @child.should_receive(:before_delete).once.and_return(true)
        db.objects.delete(@object).should be_true
      end

      it 'should fire :delete on deleted objects in update' do
        db.objects.save(@object).should be_true
        @object.children.clear
        @child.should_receive(:before_delete).once.and_return(true)
        db.objects.save(@object).should be_true
      end

      it 'should fire :create on new objects in update' do
        db.objects.save(@object).should be_true
        child2 = embedded_object_class.new
        @object.children << child2
        child2.should_receive(:before_create).once.and_return(true)
        child2.should_not_receive(:before_update)
        db.objects.save(@object).should be_true
      end
    end

    it "should fire :after_build callback after building the object" do
      class SpecialMainObject < MainObject
        def run_after_callbacks method, options
          self.class.build_callback if method == :build
        end
      end

      player = SpecialMainObject.new
      db.objects.save! player

      SpecialMainObject.should_receive :build_callback
      db.objects.first
    end
  end
end