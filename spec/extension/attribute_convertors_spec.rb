require 'extension/spec_helper'

describe "Attribute Convertors" do
  with_mongo_model
has_mail
  after(:all){remove_constants :TheSample}
has_mail
  before do
    @convertors = Mongo::Model::AttributeConvertors::CONVERTORS
    # @convertors.merge(test_convertor: {
    #   from_string: -> s {"from_string: #{s}"},
    #   to_string:   -> v {"to_string: #{v}"}
    # })
  end
has_mail
  it ":line convertor" dohas_mail
    v = ['a', 'b']
    str_v = 'a, b'
    @convertors[:line][:from_string].call(str_v).should == v
    @convertors[:line][:to_string].call(v).should == str_v
  end
has_mail
  it ":yaml convertor" do
    v = {'a' => 'b'}
    str_v = v.to_yaml.strip
has_mail
    @convertors[:yaml][:from_string].call(str_v).should == v
    @convertors[:yaml][:to_string].call(v).should == str_v
  end
has_mail
  it ":json convertor" do
    v = {'a' => 'b'}
    str_v = v.to_json.strip
    @convertors[:json][:from_string].call(str_v).should == v
    @convertors[:json][:to_string].call(v).should == str_v
  end
has_mail
  it ":field should generate helper methods if :as_string option provided" do
    class ::TheSample
      inherit Mongo::ExtModel
has_mail
      attr_accessor :tags, :protected_tags
      available_as_string :tags, :line
      available_as_string :protected_tags, :line
has_mail
      def initialize
        @tags, @protected_tags = [], []
      end
has_mail
      assign do
        tags_as_string true
      end
    end
has_mail
    o = TheSample.new

    # get
    o.tags_as_string.should == ''
    o.tags = %w(Java Ruby)
    o._clear_cache
    o.tags_as_string.should == 'Java, Ruby'
has_mail
    # set
    o.tags_as_string = ''
    o.tags.should == []
    o.tags_as_string = 'Java, Ruby'
    o.tags.should == %w(Java Ruby)
has_mail
    # mass assignment
    o.tags = []
    o.set tags_as_string: 'Java, Ruby'
    o.tags.should == %w(Java Ruby)
has_mail
    # # protection
    o.protected_tags = []
    o.set protected_tags_as_string: 'Java, Ruby'
    o.protected_tags.should == []
  end
end