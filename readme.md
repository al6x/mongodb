**Documentation:** http://alexeypetrushin.github.com/mongodb

Persistence for any Ruby Object & Driver enhancements for MongoDB.

1. Driver enhancements.
2. Migrations.
3. Persistence for any Ruby object.
4. Object Model [mongodb_model][mongodb_model]

Lower layers are independent from upper, use only what You need.

# MongoDB driver enhancements

MongoDB itself is very powerful, flexible and simple tool, but the API of the Ruby driver is a little complicated.
These enhancements alter the driver's API and made it more simple and intuitive.

- Makes API of mongo-ruby-driver friendly & handy.
- No extra abstraction or complexities introduced, all things are exactly the same as in MongoDB.
- 100% backward compatibility with original driver API (if not - it's a bug, report it please)

``` ruby
# Requiring driver enhancements.
require 'mongo/driver'

# Changing some defaults (optional, don't do it if You don't need it).
#
# By default they are set to false to provide maximum performance, but if You use MongoDB as
# major application database (and not only for logging, andalytics and other minor tasks) it's
# usually better to set it to true.
Mongo.defaults.merge! multi: true, safe: true

# Connecting to test database and cleaning it before starting the sample.
connection = Mongo::Connection.new
db = connection.default_test
db.drop

# Collection shortcuts, access collection directly by typing its name,
# instead of `db.collection('some_collection')`.
db.some_collection

# Let's create two Heroes.
db.units.save name: 'Zeratul'
db.units.save name: 'Tassadar'

# Querying first and all documents matching criteria (there's
# also `:each` method, the same as `:all`).
p db.units.first(name: 'Zeratul')                  # => zeratul
p db.units.all(name: 'Zeratul')                    # => [zeratul]
db.units.all name: 'Zeratul' do |unit|
  p unit                                           # => zeratul
end

# Dynamic finders, handy way to do simple queries.
p db.units.by_name('Zeratul')                      # => zeratul
p db.units.first_by_name('Zeratul')                # => zeratul
p db.units.all_by_name('Zeratul')                  # => [zeratul]

# Bang versions, will raise error if nothing found.
p db.units.first!(name: 'Zeratul')                 # => zeratul
p db.units.by_name!('Zeratul')                     # => zeratul

# Query sugar, use `:_gt` instead of `:$gt`. It's more convinient to use new hash
# syntax `{name: {_gt: 'Z'}}` instead of hashrockets `{name: {:$gt => 'Z'}}`.
Mongo.defaults[:convert_underscore_to_dollar] = true
p db.units.all(name: {_gt: 'Z'})                   # => [zeratul]
```

Source: docs/driver.rb

More docs - there's no need for more docs, the whole point of this extension is to be small, intuitive, 100% compatible with the official driver, and require no extra knowledge.
So, please use standard Ruby driver documentation.

# Migrations

Define migration steps, specify desired version and apply it (usually all this should be done via Rake task).

``` ruby
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
```

Source: docs/migration.rb

# Persistence for any Ruby object

Save any Ruby object to MongoDB, as if it's a document. Objects can be any type, simple or composite with other objects / arrays / hashes inside.

Note: the :initialize method should allow to create object without arguments.

``` ruby
# Connecting to test database and cleaning it before starting the sample.
require 'mongo/object'
connection = Mongo::Connection.new
db = connection.default_test
db.drop

# Let's define Game Unit.
class Unit
  # Including Mongo::Object.
  include Mongo::Object

  attr_reader :name, :stats

  # We need the initializer to be used also without arguments.
  def initialize name = nil, stats = nil
    @name, @stats = name, stats
  end

  # Creating internal object containing stats of the Unit.
  class Stats
    include Mongo::Object
    attr_accessor :attack, :life, :shield

    def initialize attack = nil, life = nil, shield = nil
      @attack, @life, @shield = attack, life, shield
    end
  end
end

# Let's create two Heroes.
#
# It uses the same Driver API, everything works the same way as with hashes.
zeratul  = Unit.new('Zeratul',  Unit::Stats.new(85, 300, 100))
tassadar = Unit.new('Tassadar', Unit::Stats.new(0,  80,  300))

db.units.save zeratul
db.units.save tassadar

# Udating, we made error - mistakenly set Tassadar's attack as zero, let's fix it.
tassadar.stats.attack = 20
db.units.save tassadar

# Querying first and all documents matching criteria (there's also `:each` method,
# the same as `:all`).
p db.units.first(name: 'Zeratul')                  # => zeratul
p db.units.all(name: 'Zeratul')                    # => [zeratul]
db.units.all name: 'Zeratul' do |unit|
  p unit                                           # => zeratul
end

# Dynamic finders, handy way to do simple queries.
p db.units.by_name('Zeratul')                      # => zeratul
p db.units.first_by_name('Zeratul')                # => zeratul
p db.units.all_by_name('Zeratul')                  # => [zeratul]

# Bang versions, will raise error if nothing found.
p db.units.first!(name: 'Zeratul')                 # => zeratul
p db.units.by_name!('Zeratul')                     # => zeratul

# Query sugar, use `:_gt` instead of `:$gt`. It's more convinient to use new hash
# syntax `{name: {_gt: 'Z'}}` instead of hashrockets `{name: {:$gt => 'Z'}}`.
Mongo.defaults[:convert_underscore_to_dollar] = true
p db.units.all(name: {_gt: 'Z'})                   # => [zeratul]
```

Source: docs/object.rb

# Installation

``` bash
gem install mongodb
```

# License

Copyright (c) Alexey Petrushin, http://petrush.in, released under the MIT license.

[mongo_mapper_ext]: https://github.com/alexeypetrushin/mongo_mapper_ext
[mongoid_misc]: https://github.com/alexeypetrushin/mongoid_misc
[code_stats]: https://github.com/alexeypetrushin/mongodb/raw/master/docs/code_stats.png
[mongodb_model]: https://github.com/alexeypetrushin/mongodb_model