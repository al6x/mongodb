module Mongo::DBExt
  def drop
    connection.drop_database name
  end

  def clear
    collection_names.each do |name|
      next if name =~ /^system\./
      mongo.db.collection(name).drop
    end
  end

  protected
    def method_missing collection_name
      self.collection collection_name
    end
end