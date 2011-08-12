Mongo::DB.class_eval do
  protected
    def method_missing collection_name
      self.collection collection_name
    end
end