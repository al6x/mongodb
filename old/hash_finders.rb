module Mongo::CollectionFinders
  def where &block
    Mongo::Query.new self, &block
  end
end