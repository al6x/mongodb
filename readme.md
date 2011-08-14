Object Model & Ruby driver enhancements for MongoDB.

- Driver enchancements
- Persistence for pure Ruby objects
- Migrations (work in progress)
- Object Model (callbacks, validations, mass-assignment, finders, ...) (work in progress)

# MongoDB driver enhancements

MongoDB itself is very powerful, flexible and simple tool, but it's Ruby driver has a little complicated API.
This enhancements alter this API to be more simple and intuitive.

- Makes API of mongo-ruby-driver friendly & handy.
- No extra abstraction or complexities introduced, all things are exactly the same as in MongoDB.
- 100% backward compatibility with original driver API (if not - it's a bug, report it please)

``` ruby
require 'mongo_db/driver/core'

# changing some defaults
Mongo.defaults.merge! symbolize: true, multi: true, safe: true

# connection & db
connection = Mongo::Connection.new
db = connection.db 'default_test'

# create
zeratul =  {name: 'Zeratul',  stats: {attack: 85, life: 300, shield: 100}}
tassadar = {name: 'Tassadar', stats: {attack: 0,  life: 80,  shield: 300}}

db.units.save zeratul
db.units.save tassadar

# udate (we made error - mistakenly set Tassadar's attack as zero, let's fix it)
tassadar[:stats][:attack] = 20
db.units.save tassadar

# querying - first & all, there's also :each, the same as :all
db.units.first name: 'Zeratul'                      # => zeratul
db.units.all name: 'Zeratul'                        # => [zeratul]
db.units.all name: 'Zeratul' do |unit|
  unit                                              # => zeratul
end
```

Optionall stuff:

- Simple query enchancements

``` ruby
require 'mongo_db/driver/more'

# simple finders (bang versions also availiable)
db.units.by_name 'Zeratul'                         # => zeratul
db.units.first_by_name 'Zeratul'                   # => zeratul
db.units.all_by_name 'Zeratul'                     # => [zeratul]

# query sugar, use {life: {_lt: 100}} instead of {life: {:$lt => 100}}
Mongo.defaults.merge! convert_underscore_to_dollar: true
db.units.all 'stats.life' => {_lt: 100}            # => [tassadar]
```

More docs - there's no need for more docs, the whole point of this extension is to be small, intuitive, 100% compatible with the official driver (at least should be), and require no extra knowledge.
So, please use standard Ruby driver documentation.

# Persistence for pure Ruby objects

Save any Ruby object to MongoDB, as if it's hash. Object can be any type, simple or composite with other objects / arrays / hashes inside.

Note: the :initialize method should allow to create object without arguments.

``` ruby
# let's define the game unit
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

# connecting to MongoDB
require 'mongo_db/model'
Mongo.defaults.merge! symbolize: true, multi: true, safe: true
connection = Mongo::Connection.new
db = connection.db 'default_test'

# create
zeratul  = Unit.new('Zeratul',  Unit::Stats.new(85, 300, 100))
tassadar = Unit.new('Tassadar', Unit::Stats.new(0,  80,  300))

db.units.save zeratul
db.units.save tassadar

# udate (we made error - mistakenly set Tassadar's attack as zero, let's fix it)
tassadar.stats.attack = 20
db.units.save tassadar

# querying first & all, there's also :each, the same as :all
db.units.first name: 'Zeratul'                     # => zeratul
db.units.all name: 'Zeratul'                       # => [zeratul]
db.units.all name: 'Zeratul' do |unit|
  unit                                             # => zeratul
end

# simple finders (bang versions also availiable)
db.units.by_name 'Zeratul'                         # => zeratul
db.units.first_by_name 'Zeratul'                   # => zeratul
db.units.all_by_name 'Zeratul'                     # => [zeratul]

# query sugar, use {life: {_lt: 100}} instead of {life: {:$lt => 100}}
Mongo.defaults.merge! convert_underscore_to_dollar: true
db.units.all('stats.life' => {_lt: 100})           # => [tassadar]
```

# Migrations (work in progress)

# Object Model (work in progress)

Model designed after the excellent "Domain-Driven Design" book by Eric Evans.

- Very small.
- Minimum extra abstraction, trying to keep things as close to the MongoDB semantic as possible.
- Schema-less, dynamic (with ability to specify types for mass-assignment).
- Models can be saved to any collection.
- Full support for embedded objects (and MDD composite pattern).
- Doesn't try to mimic ActiveRecord, it's differrent and designed to get most of MongoDB.

# Installation & Usage

Installation:

``` bash
gem install mongo_db
```

Usage:

``` ruby
require 'mongo_db/driver'
```

# License

Copyright (c) Alexey Petrushin, http://petrush.in, released under the MIT license.

[mongo_mapper_ext]: https://github.com/alexeypetrushin/mongo_mapper_ext
[mongoid_misc]: https://github.com/alexeypetrushin/mongoid_misc