require 'driver/spec_helper'

describe 'Test' do
  with_mongo

  it do
    class A; end
    db.units.save a: A.new
  end
end