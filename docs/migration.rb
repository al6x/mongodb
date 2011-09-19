# Example of Data Migration for [MongoDB Enhanced Driver][mongodb].
#
# In this example we'll define two migrations, applying first one,
# rollback it, and then migrating database to the latest version.
#
# Usually all this is [done via Rake Task][rake_migration], but in this example we do
# it by hand.

# Requiring support for migration.
require 'mongo/migration'

# Defining first migration, creating Zeratul (and removing it in rollback).
Mongo.migration 1 do |m|
  m.up  {|db| db.units.save   name: 'Zeratul'}
  m.down{|db| db.units.remove name: 'Zeratul'}
end

# Defining second migration, creating Tassadar (and removing it in rollback).
Mongo.migration 2 do |m|
  m.up  {|db| db.units.save   name: 'Tassadar'}
  m.down{|db| db.units.remove name: 'Tassadar'}
end

# Connecting to test database and cleaning it before starting the sample.
connection = Mongo::Connection.new
db = connection.default_test
db.drop

# Assigning database to migration.
Mongo.migration.db = db

# Let's migrate to the first version and create mighty Zeratul.
Mongo.migration.update 1

p Mongo.migration.current_version                # => 1
p db.units.all                                   # => [Zeratul]

# Rolling it back.
Mongo.migration.update 0

p Mongo.migration.current_version                # => 0
p db.units.all                                   # => []

# Updating to the latest version (if there's no explicit version
# then the highest available version will be chosen).
Mongo.migration.update

p Mongo.migration.current_version                # => 2
p db.units.all                                   # => [Zeratul, Tassadar]

# [mongodb]:        index.html
# [rake_migration]: rake_migration.html