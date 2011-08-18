# require 'spec_helper'
#
# describe 'Object callbacks' do
#   with_mongo
#
#   def expand_names *names
#     names.collect{|name| "before_#{name}".to_sym} + names.reverse.collect{|name| "after_#{name}".to_sym}
#   end
#
#   before do
#     class Player
#       attr_accessor :missions
#
#       class Mission
#       end
#     end
#
#     @mission = Player::Mission.new
#     @player = Player.new
#     @player.missions = [@mission]
#   end
#   after{remove_constants :Player}
#
#   it 'create', focus: true do
#     expand_names(:validate, :save, :create).each do |name|
#       @player.should_receive(:run_callbacks).with(name).ordered
#       @misson.should_receive(:run_callbacks).with(name).ordered
#     end
#
#     db.players.save @player
#   end
#
#   it 'update' do
#     db.players.save @player
#
#     expand_names(:validate, :save, :update).each do |name|
#       @player.should_receive(:run_callbacks).with(name).ordered
#       @misson.should_receive(:run_callbacks).with(name).ordered
#     end
#     db.players.save @player
#   end
#
#   it 'destroy' do
#     db.players.save @player
#
#     expand_names(:validate, :destroy).each do |name|
#       @player.should_receive(:run_callbacks).with(name).ordered
#       @misson.should_receive(:run_callbacks).with(name).ordered
#     end
#     db.players.destroy @player
#   end
#
#   it 'should be able skip callbacks' do
#     @player.should_not_receive(:run_callbacks)
#     @misson.should_not_receive(:run_callbacks)
#
#     db.players.save @player, callbacks: false
#     db.players.count.should == 1
#     db.players.save @player, callbacks: false
#     db.players.count.should == 1
#     db.players.destroy @player, callbacks: false
#     db.players.count.should == 0
#   end
#
#
#
#
#
#
#
#
#
#   # it 'should be able interrupt CRUD' do
#   #   @misson.stub!(:run).and_return(false)
#   #   db.players.save(@player).should be_false
#   #   db.players.count.should == 0
#   # end
#
# end