Object Model & Ruby driver enhancements for MongoDB.

1. Driver enchancements & Migrations.
2. Persistence for any Ruby object.
3. Object Model (callbacks, validations, mass-assignment, finders, ...).

Lower layers are independent from upper, use only what You need.

# MongoDB driver enhancements

MongoDB itself is very powerful, flexible and simple tool, but the API of the Ruby driver is a little complicated.
These enhancements alter the driver's API and made it more simple and intuitive.

- Makes API of mongo-ruby-driver friendly & handy.
- No extra abstraction or complexities introduced, all things are exactly the same as in MongoDB.
- 100% backward compatibility with original driver API (if not - it's a bug, report it please)

``` ruby
require 'mongo_db/driver'

# Changing some defaults.
Mongo.defaults.merge! symbolize: true, multi: true, safe: true

# Connection & db.
connection = Mongo::Connection.new
db = connection.db 'default_test'
db.units.drop

# Collection shortcuts.
db.some_collection

# Create.
zeratul =  {name: 'Zeratul',  stats: {attack: 85, life: 300, shield: 100}}
tassadar = {name: 'Tassadar', stats: {attack: 0,  life: 80,  shield: 300}}

db.units.save zeratul
db.units.save tassadar

# Udate (we made error - mistakenly set Tassadar's attack as zero, let's fix it).
tassadar[:stats][:attack] = 20
db.units.save tassadar

# Querying first & all, there's also :each, the same as :all.
db.units.first name: 'Zeratul'                     # => zeratul
db.units.all name: 'Zeratul'                       # => [zeratul]
db.units.all name: 'Zeratul' do |unit|
  unit                                             # => zeratul
end

# Dynamic Finders (bang versions also availiable).
db.units.by_name 'Zeratul'                         # => zeratul
db.units.first_by_name 'Zeratul'                   # => zeratul
db.units.all_by_name 'Zeratul'                     # => [zeratul]

# Query sugar, use {name: {_gt: 'Z'}} instead of {name: {:$gt => 'Z'}}.
Mongo.defaults.merge! convert_underscore_to_dollar: true
db.units.all name: {_gt: 'Z'}                      # => [zeratul]
```

Source: examples/driver.rb

More docs - there's no need for more docs, the whole point of this extension is to be small, intuitive, 100% compatible with the official driver, and require no extra knowledge.
So, please use standard Ruby driver documentation.

# Persistence for any Ruby object

Save any Ruby object to MongoDB, as if it's a document. Objects can be any type, simple or composite with other objects / arrays / hashes inside.

Note: the :initialize method should allow to create object without arguments.

``` ruby
# Let's define the game unit.
class Unit
  attr_reader :name, :stats

  # don't forget to allow creating object with no arguments
  def initialize name = nil, stats = nil
    @name, @stats = name, stats
  end

  class Stats
    attr_accessor :attack, :life, :shield

    def initialize attack = nil, life = nil, shield = nil
      @attack, @life, @shield = attack, life, shield
    end
  end
end

# Connecting to MongoDB.
require 'mongo_db/object'
Mongo.defaults.merge! symbolize: true, multi: true, safe: true
connection = Mongo::Connection.new
db = connection.db 'default_test'
db.units.drop

# Create.
zeratul  = Unit.new('Zeratul',  Unit::Stats.new(85, 300, 100))
tassadar = Unit.new('Tassadar', Unit::Stats.new(0,  80,  300))

db.units.save zeratul
db.units.save tassadar

# Udate (we made error - mistakenly set Tassadar's attack as zero, let's fix it).
tassadar.stats.attack = 20
db.units.save tassadar

# Querying first & all, there's also :each, the same as :all.
db.units.first name: 'Zeratul'                     # => zeratul
db.units.all name: 'Zeratul'                       # => [zeratul]
db.units.all name: 'Zeratul' do |unit|
  unit                                             # => zeratul
end

# Simple finders (bang versions also availiable).
db.units.by_name 'Zeratul'                         # => zeratul
db.units.first_by_name 'Zeratul'                   # => zeratul
db.units.all_by_name 'Zeratul'                     # => [zeratul]

# Query sugar, use {name: {_gt: 'Z'}} instead of {name: {:$gt => 'Z'}}.
Mongo.defaults.merge! convert_underscore_to_dollar: true
db.units.all name: {_gt: 'Z'}                      # => [zeratul]
```

Source: examples/object.rb

# Object Model

- The same API for pure driver and Models.
- Minimum extra abstractions, trying to keep things as close to the MongoDB semantic as possible.
- Schema-less, dynamic (with ability to specify types for mass-assignment).
- Models can be saved to any collection.
- Full support for embedded objects (validations, callbacks, ...).
- Scope, default_scope
- Doesn't try to mimic ActiveRecord, MongoDB is differrent and this tool designed to get most of it.
- Very small, see [code stats][code_stats].

Other ODM usually try to cover simple but non-standard API of MongoDB behind complex ORM-like abstractions. This tool **exposes simplicity and power of MongoDB and leverages it's differences**.

``` ruby
# Connecting to MongoDB.
require 'mongo_db/model'
Mongo.defaults.merge! symbolize: true, multi: true, safe: true
connection = Mongo::Connection.new
db = connection.db 'default_test'
db.units.drop
Mongo::Model.db = db

# Let's define the game unit.
class Unit
  inherit Mongo::Model
  collection :units

  attr_accessor :name, :status, :stats

  scope :alive, status: 'alive'

  class Stats
    inherit Mongo::Model
    attr_accessor :attack, :life, :shield
  end
end

# Create.
zeratul  = Unit.build(name: 'Zeratul',  status: 'alive', stats: Unit::Stats.build(attack: 85, life: 300, shield: 100))
tassadar = Unit.build(name: 'Tassadar', status: 'dead',  stats: Unit::Stats.build(attack: 0,  life: 80,  shield: 300))

zeratul.save
tassadar.save

# Udate (we made error - mistakenly set Tassadar's attack as zero, let's fix it).
tassadar.stats.attack = 20
tassadar.save

# Querying first & all, there's also :each, the same as :all.
Unit.first name: 'Zeratul'                         # => zeratul
Unit.all name: 'Zeratul'                           # => [zeratul]
Unit.all name: 'Zeratul' do |unit|
  unit                                             # => zeratul
end

# Simple finders (bang versions also availiable).
Unit.by_name 'Zeratul'                             # => zeratul
Unit.first_by_name 'Zeratul'                       # => zeratul
Unit.all_by_name 'Zeratul'                         # => [zeratul]

# Scopes.
Unit.alive.count                                   # => 1
Unit.alive.first                                   # => zeratul

# Callbacks & callbacks on embedded models.

# Validations.

# Save model to any collection.
```

Source: examples/model.rb

# Migrations

Define migration steps, specify desired version and apply it (usually all this should be done via Rake task).

``` ruby
require 'mongo_db/migration'

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
```

Source: examples/migration.rb

# Installation

``` bash
gem install mongo_db
```

# License

Copyright (c) Alexey Petrushin, http://petrush.in, released under the MIT license.

[mongo_mapper_ext]: https://github.com/alexeypetrushin/mongo_mapper_ext
[mongoid_misc]: https://github.com/alexeypetrushin/mongoid_misc
[code_stats]: https://github.com/alexeypetrushin/mongo_db/raw/master/docs/code_stats.png