module Mongo::DynamicFinders
  def where &block
    Mongo::Query.new self, &block
  end
end