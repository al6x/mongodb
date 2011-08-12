Object Model & Ruby driver enhancements for MongoDB

# MongoDB driver enhancements

- Makes alien API of mongo-ruby-driver friendly & handy.
- No extra abstraction or complexities introduced, all things are exactly the same as in MongoDB.
- Simple migrations support (work in progress).

Sample:

``` ruby
require 'mongo_db/driver'

# connection & db
connection = Mongo::Connection.new
db = connection.db 'default_test'

# collection shortcuts
db.some_collection

# save & update
zeratul = {name: 'Zeratul'}
db.heroes.save zeratul

# first & all    
db.heroes.first name: 'Zeratul'                     # => {name: 'Zeratul'}

db.heroes.all name: 'Zeratul'                       # => [{name: 'Zeratul'}]
db.heroes.all name: 'Zeratul' do |hero|
  hero                                              # => {name: 'Zeratul'}
end    

# each: db.each(&block) is the same as db.all(&block)
```

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