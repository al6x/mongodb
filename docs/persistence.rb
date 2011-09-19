# Example of Ruby Object Persistence for [MongoDB Enhanced Driver][mongodb].
#
# Object Persistence allows You to save any Ruby Object to MongoDB as if it's
# a Document. Objects can be any type, simple or composite with other
# objects / arrays / hashes inside.
#
# It works by converting object graph to graph of hashes when saving to mongo,
# and restoring it back when loading.
#
# Objects are converted to hashes by walking over instance variables and converting them
# to hash entries. Because it uses such simple approach any Ruby Object can
# be easily saved to Mongo.

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

# In this example we covered Ruby Object Persistence, if You are interesting You can also take
# a look at [mongodb_model][mongodb_model] - Object Model to define Business Logic of
# Your Application (standalone gem).
#
# [mongodb]:       index.html
# [mongodb_model]: http://alexeypetrushin.github.com/mongodb_model