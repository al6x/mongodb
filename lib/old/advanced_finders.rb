before do
  @zeratul =  {name: 'Zeratul',  stats: {attack: 85, life: 300, shield: 100}}
  @tassadar = {name: 'Tassadar', stats: {attack: 20,  life: 80,  shield: 300}}

  db.units.save @zeratul
  db.units.save @tassadar
end










it "selector" do
  db.units.select{|u|
    u.stats.life < 100
    u.name.exist
    u.name.in
  }.first.should == @tassadar

  db.units.select{|u| }
end