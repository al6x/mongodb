Mongo.class_eval do
  class << self
    def migration *args, &block
      if block
        version, database_name = *args
        version or raise("migration version not provided!")
        database_name ||= :default
        add_migration version, database_name, &block
      elsif !block
        database_name = args.first
        database_name ||= :default
        get_migration(database_name)
      end
    end

    def add_migration version, database_name, &block
      get_migration(database_name).add version, &block
    end

    def get_migration database_name
      migrations[database_name] ||= Mongo::Migration.new
    end

    def migrations; @migrations ||= {} end
  end
end