class Mongo::Migration
  def initialize
    @definitions = {}
  end

  def add version, &block
    raise "version should be an Integer! (but you provided '#{version}' instad)!" unless version.is_a? Integer
    definition = Definition.new
    block.call definition
    definitions[version] = definition
  end

  def update version = nil
    version ||= definitions.keys.max
    version = version.to_i

    if current_version == version
      info "database '#{db.name}' already is of #{version} version, no migration needed"
      return false
    else
      info "updating '#{db.name}' to #{version}"
    end

    increase_db_version while current_version < version
    decrease_db_version while current_version > version
    true
  end

  def current_version
    if doc = db.db_metadata.first(name: 'migration')
      doc[:version] || doc['version']
    else
      0
    end
  end

  attr_writer :db
  def db; @db || raise("Database for Migration not defined!") end

  def update_version new_version
    db.db_metadata.update({name: 'migration'}, {name: 'migration', version: new_version}, {upsert: true, safe: true})
  end

  attr_accessor :definitions

  protected
    def info msg
      db.connection.logger and db.connection.logger.info(msg)
    end

    def increase_db_version
      new_version = current_version + 1
      migration = definitions[new_version]
      raise "no upgrade of #{db.name} database to #{new_version} version!" unless migration and migration.up

      migration.up.call db
      update_version new_version

      info "database '#{db.name}' upgraded to #{new_version} version."
    end

    def decrease_db_version
      new_version = current_version - 1
      migration = definitions[new_version + 1]
      raise "no downgrade of #{db.name} database to #{new_version} version!" unless migration and migration.down

      migration.down.call db
      update_version new_version

      info "database '#{db.name}' downgraded to #{new_version} version."
    end
end