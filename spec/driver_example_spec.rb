require 'driver/spec_helper'

describe "Example" do
  with_mongo
  
  defaults = nil
  before(:all){defaults = Mongo.defaults.clone}
  after(:all){Mongo.defaults = defaults}
  
  it "core" do    
    require 'mongo_db/driver'  
    
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
    db.units.all name: 'Zeratul' do |hero|
      hero                                             # => zeratul
    end
  end
  
  it "optional" do        
    # simple finders (bang versions also availiable)
    db.units.by_name 'Zeratul'                         # => zeratul
    db.units.first_by_name 'Zeratul'                   # => zeratul
    db.units.all_by_name 'Zeratul'                     # => [zeratul]
    
    # query sugar, use {life: {_lt: 100}} instead of {life: {:$lt => 100}}
    # it will affect olny small set of keywords (:_lt, :_inc),
    # other underscored keys will be intact.
    Mongo.defaults.merge! convert_underscore_to_dollar: true    
    db.units.all life: {_lt: 100}                      # => [tassadar]
    
    # it's also trivial to add support for {:life.lt => 100} notion, but
    # it uses ugly '=>' hash notation instead of ':' and it differs from
    # how it looks in native MongoDB JSON query.
  end
end