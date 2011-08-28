module Mongo::DBExt
  protected
    def method_missing collection_name
      self.collection collection_name
    end
end