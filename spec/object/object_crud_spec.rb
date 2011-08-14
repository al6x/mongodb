require 'object/spec_helper'
require 'object/crud_shared'

describe "Object CRUD" do
  with_mongo

  describe 'simple' do
    before do
      class Person
        def initialize name = nil, info = nil; @name, @info = name, info end
        attr_accessor :name, :info
        def == o; [self.class, name, info] == [o.class, o.respond_to(:name), o.respond_to(:info)] end
      end

      @zeratul = Person.new 'Zeratul', 'Dark Templar'
    end
    after{remove_constants :Person}

    it_should_behave_like "object CRUD"
  end

  describe 'embedded' do
    before do
      class Player
        attr_accessor :missions
        def == o; [self.class, self.missions] == [o.class, o.respond_to(:missions)] end

        class Mission
          def initialize name = nil, stats = nil; @name, @stats = name, stats end
          attr_accessor :name, :stats
          def == o; [self.class, self.name, self.stats] == [o.class, o.respond_to(:name), o.respond_to(:stats)] end
        end
      end

      @player = Player.new
      @player.missions = [
        Player::Mission.new('Wasteland',         {buildings: 5, units: 10}),
        Player::Mission.new('Backwater Station', {buildings: 8, units: 25}),
      ]
    end
    after{remove_constants :Player}

    it_should_behave_like 'embedded object CRUD'
  end
end