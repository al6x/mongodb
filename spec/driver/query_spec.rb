require 'driver/spec_helper'

describe "Querying" do
  with_mongo
  
  it "database & collection" do
    # collection shortcuts
    db.some_collection
    
    # create
    zeratul = {
      name: 'Zeratul',
      stats: {attack: 85, life: 300, shield: 100}
    }
    db.heroes.save zeratul
    
    tassadar = {
      name: 'Tassadar',
      stats: {attack: 0, life: 80, shield: 300}
    }    
    db.heroes.save tassadar
    
    # udate (we made error and mistakenly set Tassadar's attack as zero, let's fix it)
    tassadar[:stats][:attack] = 20
    db.heroes.save tassadar    
    
    # querying first & all (there's also :each, the same as :all)
    db.heroes.first name: 'Zeratul'                     # => {name: 'Zeratul'}
    
    db.heroes.select{|h| h.name == 10}.first

    db.heroes.all name: 'Zeratul'                       # => [{name: 'Zeratul'}]
    db.heroes.all name: 'Zeratul' do |hero|
      hero                                              # => {name: 'Zeratul'}
    end    
    
    # let's do some magic
    # don't worry, it's contained and guarded
    
  end
end