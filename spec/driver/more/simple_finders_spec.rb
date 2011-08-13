require 'driver/spec_helper'

describe "Querying" do
  with_mongo
  
  before do
    @jim =  {name: 'Jim'}
    @units = db.units
  end
    
  it "find, first, by" do
    @units.first_by_name('Jim').should be_nil    
    -> {@units.first_by_name!('Jim')}.should raise_error(Mongo::NotFound)
    @units.by_name('Jim').should be_nil    
    -> {@units.by_name!('Jim')}.should raise_error(Mongo::NotFound)
    @units.first_by_name('Jim').should be_nil    
    -> {@units.first_by_name!('Jim')}.should raise_error(Mongo::NotFound)
    
    @units.save @jim
    
    @units.first_by_name('Jim').should == @jim
    @units.first_by_name!('Jim').should == @jim
    @units.by_name('Jim').should == @jim
    @units.by_name!('Jim').should == @jim
    @units.first_by_name('Jim').should == @jim
    @units.first_by_name!('Jim').should == @jim
  end
  
  it "all" do
    @units.all_by_name('Jim').should == []    
    @units.save @jim
    @units.all_by_name('Jim').should == [@jim]
  end
  
  it "should allow to use bang version only with :first" do
    -> {@units.all_by_name!('Jim')}.should raise_error(/can't use bang/)
  end
  
  it "by_id (special case)" do
    @units.method(:by_id).should == @units.method(:first_by_id)
    @units.method(:by_id!).should == @units.method(:first_by_id!)
    
    @units.by_id('4de81858cf26bde569000009').should be_nil    
    -> {@units.by_id!('4de81858cf26bde569000009')}.should raise_error(Mongo::NotFound)
    
    @units.save @jim
    
    @units.by_id(@jim[:_id]).should == @jim
    @units.by_id!(@jim[:_id]).should == @jim
  end
end