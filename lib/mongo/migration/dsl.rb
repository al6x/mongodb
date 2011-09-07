Mongo.class_eval do
  class << self
    def migration version, database_name = :default, &block
      migration = (migrations[database_name] ||= Mongo::Migration.new)
      migration.add version, &block
    end

    def migrations
      @migrations ||= {}
    end
  end
end