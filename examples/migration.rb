require 'mongo/migration'

# Connection & db.
connection = Mongo::Connection.new
db = connection.db 'default_test'
db.units.drop

# Initialize migration (usually all this should be done inside of :migrate
# rake task).
migration = Mongo::Migration.new db

# Define migrations.
# Usually they are defined as files in some folder and You loading it by
# using something like this:
#   Dir['<runtime_dir>/db/migrations/*.rb'].each{|fname| load fname}
migration.add 1 do |m|
  m.up{|db|   db.units.save   name: 'Zeratul'}
  m.down{|db| db.units.remove name: 'Zeratul'}
end

# Let's add another one.
migration.add 2 do |m|
  m.up{|db|   db.units.save   name: 'Tassadar'}
  m.down{|db| db.units.remove name: 'Tassadar'}
end

# Specify what version of database You need and apply migration.
migration.update 2

migration.current_version                        # => 2
db.units.count                                   # => 2

# You can rollback it the same way.
migration.update 0

migration.current_version                        # => 0
db.units.count                                   # => 0

# To update to the highest version just call it without the version specified
migration.update

migration.current_version                        # => 2
db.units.count                                   # => 2