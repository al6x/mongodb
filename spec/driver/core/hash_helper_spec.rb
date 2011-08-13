require 'driver/spec_helper'

describe "HashHelper" do
  it "symbolize" do
    Mongo::Ext::HashHelper.symbolize({
      'a' => 1,
      'b' => {
        'c' => 2,
        'd' => [{'e' => 3}]
      }
    }).should == {
      a: 1,
      b: {
        c: 2,
        d: [{e: 3}]
      }
    }
  end
end