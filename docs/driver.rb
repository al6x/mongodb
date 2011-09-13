# Enhancements for MongoDB Ruby Driver.
#
# 1. Driver enhancements (see example below).
# 2. [Data Migration][migration].
# 3. [Persistence for Ruby Objects][persistence].
# 4. [mongodb_model][mongodb_model] - Object Model to define Business Logic of
# Your Application (standalone gem).
#
# Lower layers are independent from upper, use only what You need.
#
# Install mongodb with Rubygems:
#
#     gem install mongodb
#
# Once installed, You can proceed with the examples.
#
# The project is [hosted on GitHub][project]. You can report bugs and discuss features
# on the [issues page][issues].

# ### Driver example
#
# MongoDB itself is very powerful, flexible and simple tool, but the API of the Ruby Driver
# is a little complicated.
#
# These enhancements carefully alter Driver's API and made it more simple and intuitive
# (but still 100% backward compatible).
#
# - Makes API of MongoDB Ruby Driver friendly & handy.
# - No extra abstraction or complexities introduced, all things are exactly the same as in MongoDB.
# - 100% backward compatibility with original Driver API (if not - it's a bug, report it please).

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

# In this example we covered enhancements of MongoDB Ruby Driver, if You are interesting
# You can also take a look at [Data Migration][migration]
# and [Persistence for Ruby Objects][persistence] examples.
#
# [migration]:     migration.html
# [persistence]:   persistence.html
#
# [mongodb_model]: http://alexeypetrushin.github.com/mongodb_model
#
# [project]:       https://github.com/alexeypetrushin/mongodb
# [issues]:        https://github.com/alexeypetrushin/mongodb