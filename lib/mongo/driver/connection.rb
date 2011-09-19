module Mongo::ConnectionExt
  attr_writer :logger

  protected
    def method_missing db_name
      self.db db_name.to_s
    end
end