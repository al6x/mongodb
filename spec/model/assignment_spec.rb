require 'model/spec_helper'

describe 'Model callbacks' do
  with_mongo

  after{remove_constants :User, :Writer}

  it "should update attributes" do
    class User
      inherit Mongo::Model

      attr_accessor :name, :active, :age, :banned
    end

    u = User.new
    u.set name: 'Alex', active: '1', age: '31', banned: '0'
    [u.name, u.active, u.age, u.banned].should == ['Alex', '1', '31', '0']
  end

  it "should update only specified attributes" do
    class User
      inherit Mongo::Model

      attr_accessor :name, :active, :age, :banned

      assignment do
        name     String,  true
        active   Boolean, true
        age      Integer, true
        banned   Boolean
      end
    end

    u = User.new
    u.set name: 'Alex', active: '1', age: '31', password: 'fake'
    [u.name, u.active, u.age, u.banned].should == ['Alex', true, 31, nil]

    # should allow to forcefully cast and update any attribute
    u.set! banned: '0'
    u.banned.should == false
  end

  it "should inherit assignment rules" do
    class User
      inherit Mongo::Model

      attr_accessor :age

      assignment do
        age Integer,  true
      end
    end

    class Writer < User
      attr_accessor :posts

      assignment do
        posts Integer, true
      end
    end

    u = Writer.new
    u.set age: '20', posts: '12'
    [u.age, u.posts].should == [20, 12]
  end

  it 'casting smoke test' do
    [
      Boolean, '1',          true,
      Date,    '2011-08-23', Date.parse('2011-08-23'),
      Float,   '1.2',        1.2,
      Integer, '10',         10,
      String,  'Hi',         'Hi',
      Time,    '2011-08-23', Date.parse('2011-08-23').to_time
    ].each_slice 3 do |type, raw, expected|
      type.cast(raw).should == expected
    end
  end
end