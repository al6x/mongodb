namespace :db do
  desc "Clear migration version for Database"
  task clear_version: :migration_evnironment do
    require 'mongo/migration'

    database_name = (ENV['d'] || ENV['database'] || :default).to_sym

    db = Mongo.db database_name
    migration = Mongo::Migration.new
    migration.db = db
    migration.update_version 0
  end

  desc "Migrate Database"
  task migrate: :migration_evnironment do
    require 'mongo/migration'

    database_name = (ENV['d'] || ENV['database'] || :default).to_sym
    version = ENV['v'] || ENV['version']

    if migration = Mongo.migrations[database_name]
      db = Mongo.db database_name
      migration.db = db
      migration.update version
    end
  end
end