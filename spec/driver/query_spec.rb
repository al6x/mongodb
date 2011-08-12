require 'driver/spec_helper'

describe "Querying" do
  with_mongo
  
  before do
    @zeratul =  {name: 'Zeratul',  stats: {attack: 85, life: 300, shield: 100}}
    @tassadar = {name: 'Tassadar', stats: {attack: 0,  life: 80,  shield: 300}}
    
    db.units.save @zeratul
    db.units.save @tassadar
  end
  
  it "selector" do
    
  end
end