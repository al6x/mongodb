require 'mongo_db/driver/core'
require 'rspec'

describe "Driver example" do
  defaults = nil
  before(:all){defaults = Mongo.defaults.clone}
  after(:all){Mongo.defaults = defaults}

  it "core" do
    require 'mongo_db/driver/core'

    # changing some defaults
    Mongo.defaults.merge! symbolize: true, multi: true, safe: true

    # connection & db
    connection = Mongo::Connection.new
    db = connection.db 'default_test'

    # collection shortcuts
    db.some_collection

    # create
    zeratul =  {name: 'Zeratul',  stats: {attack: 85, life: 300, shield: 100}}
    tassadar = {name: 'Tassadar', stats: {attack: 0,  life: 80,  shield: 300}}

    db.units.save zeratul
    db.units.save tassadar

    # udate (we made error - mistakenly set Tassadar's attack as zero, let's fix it)
    tassadar[:stats][:attack] = 20
    db.units.save tassadar

    # querying first & all, there's also :each, the same as :all
    db.units.first name: 'Zeratul'                     # => zeratul
    db.units.all name: 'Zeratul'                       # => [zeratul]
    db.units.all name: 'Zeratul' do |unit|
      unit                                             # => zeratul
    end


    #
    # optional
    #
    require 'mongo_db/driver/more'

    # simple finders (bang versions also availiable)
    db.units.by_name 'Zeratul'                         # => zeratul
    db.units.first_by_name 'Zeratul'                   # => zeratul
    db.units.all_by_name 'Zeratul'                     # => [zeratul]

    # query sugar, use {life: {_lt: 100}} instead of {life: {:$lt => 100}}
    Mongo.defaults.merge! convert_underscore_to_dollar: true
    db.units.all 'stats.life' => {_lt: 100}            # => [tassadar]
  end
end