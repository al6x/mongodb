# Connecting to MongoDB.
require 'mongo/object'
Mongo.defaults.merge! multi: true, safe: true
connection = Mongo::Connection.new
db = connection.db 'default_test'
db.units.drop

# Let's define the game unit.
class Unit
  include Mongo::Object
  attr_reader :name, :stats

  # don't forget to allow creating object with no arguments
  def initialize name = nil, stats = nil
    @name, @stats = name, stats
  end

  class Stats
    include Mongo::Object
    attr_accessor :attack, :life, :shield

    def initialize attack = nil, life = nil, shield = nil
      @attack, @life, @shield = attack, life, shield
    end
  end
end

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
Mongo.defaults[:convert_underscore_to_dollar] = true
db.units.all name: {_gt: 'Z'}                      # => [zeratul]