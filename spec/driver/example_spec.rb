require 'driver/spec_helper'

describe "Example" do
  with_mongo
  
  it "database & collection" do
    require 'mongo_db/driver'
    
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
    
    # each
    db.heroes.each name: 'Zeratul' do |hero|
      hero                                              # => {name: 'Zeratul'}
    end
  end
end