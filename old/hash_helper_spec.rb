require 'driver/spec_helper'

describe "Collection" do
  before do
    @helper = Object.new
    @helper.send :extend, Mongo::CollectionExt
  end

  # Discarded
  # it "symbolize" do
  #   @helper.send(:symbolize_doc, {
  #     'a' => 1,
  #     'b' => {
  #       'c' => 2,
  #       'd' => [{'e' => 3}]
  #     }
  #   }).should == {
  #     a: 1,
  #     b: {
  #       c: 2,
  #       d: [{e: 3}]
  #     }
  #   }
  # end
end