require 'driver/spec_helper'

describe "Example" do
  with_mongo
  
  defaults = nil
  before(:all){defaults = Mongo.defaults.clone}
  after(:all){Mongo.defaults = defaults}
  
  it "database & collection" do
    require 'mongo_db/driver'
    
    # making defaults more suitable
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
      hero                                              # => zeratul
    end
  end
end