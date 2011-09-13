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
require 'mongo/driver'

# Changing some defaults.
Mongo.defaults.merge! multi: true, safe: true

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

# Migrations

Define migration steps, specify desired version and apply it (usually all this should be done via Rake task).

``` ruby
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
```

Source: examples/migration.rb

# Persistence for any Ruby object

Save any Ruby object to MongoDB, as if it's a document. Objects can be any type, simple or composite with other objects / arrays / hashes inside.

Note: the :initialize method should allow to create object without arguments.

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

# Collection shortcuts, access collection directly by typing it's name,
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

Source: examples/object.rb

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