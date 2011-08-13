require 'driver/spec_helper'

describe "Query" do  
  dsl_class = Mongo::Ext::Query::Dsl
  dsl_class.class_eval do
    public :statements
  end
  
  it "operators" do
    value = :value
    dsl_class.new do |o|
      o.key ==     value
      o.key !=     value
      o.key <      value
      o.key <=     value
      o.key >      value
      o.key >=     value      
      o.key.all    value
      o.key.exists true
      o.key.mod    value
      o.key.in     value
      o.key.nin    value
      o.key.size   value
      o.key.type   value
    end.statements.should == [
      [:key, :==,     :value],
      [:key, :$ne,    :value],
      [:key, :$lt,    :value],
      [:key, :$lte,   :value],
      [:key, :$gt,    :value],
      [:key, :$gte,   :value],
      [:key, :all,    :value],
      [:key, :exists, true],
      [:key, :mod,    :value],
      [:key, :in,     :value],
      [:key, :nin,    :value],
      [:key, :size,   :value],
      [:key, :type,   :value]
    ]
  end
  
  it ":nor, :or, :and"
  
  describe "statement" do
    def process_statement *args
      s = Mongo::Ext::Query::Dsl::Statement.new
      s.push *args
      result = {}
      s.add_to result
      result
    end
    
    it "basics", focus: true do
      p process_statement(:age, :$gt, 34)
    end
  end
  
  # it "to_hash" do
  #   dsl.new do |o|
  #     # o.name == 'Jim'
  #     o.age  >  34
  #   end.to_hash.should == {
  #     # name: 'Jim',
  #     :$gt => {age:  34}
  #   }
  # end
  # 
  # it do
  #   dsl.new do |unit|
  #     unit.name == 'Zeratul'
  #     unit.stats.life > 100
  #     unit.stats.attack != 0
  #   end.statement.should == {
  #     name: 1
  #   }
  # end
end