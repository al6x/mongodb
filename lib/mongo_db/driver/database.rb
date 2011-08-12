class Mongo::DB
  def method_missing collection_name
    self[collection_name]
  end
end