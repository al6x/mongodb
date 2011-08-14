module Mongo::Ext::CollectionFinders
  def where &block
    Mongo::Ext::Query.new self, &block
  end
end