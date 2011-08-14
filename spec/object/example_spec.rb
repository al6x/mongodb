require 'mongo_db/model'
require 'rspec'

describe "Object example" do
  defaults = nil
  before(:all){defaults = Mongo.defaults.clone}
  after :all do
    Mongo.defaults = defaults
    Object.send :remove_const, :Unit if Object.const_defined? :Unit
  end

  it do
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
  end
end