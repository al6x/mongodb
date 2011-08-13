Object Model & Ruby driver enhancements for MongoDB.

# MongoDB driver enhancements

MongoDB itself is very powerful, flexible and simple tool, but it's Ruby driver hides it behind complicated API.
This enhancements alter the Ruby-driver's API to be more simple and intuitive.

- Makes API of mongo-ruby-driver friendly & handy.
- No extra abstraction or complexities introduced, all things are exactly the same as in MongoDB.

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
db.units.all name: 'Zeratul' do |hero|
  hero                                              # => zeratul
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
db.units.all life: {_lt: 100}                      # => [tassadar]

# it's also trivial to add support for {:life.lt => 100} notion,
# but the '=>' symbol looks ugly and I don't like it.
```

More docs - there's no need for more docs, the whole point of this extension is to be small, intuitive, 100% compatible with the official driver (at least should be), and require no extra knowledge.
So, please use standard Ruby driver documentation.

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