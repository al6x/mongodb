module Mongo::ConnectionExt
  protected
    def method_missing db_name
      self.db db_name.to_s
    end
end