MONGO_TEST_DATABASE_NAME = 'default_test'

Mongo.class_eval do
  class << self
    def db name
      ($mongo || raise('Mongo not defined (use :with_mongo helper)!')).db
    end
  end
end

rspec do
  def mongo
    $mongo || raise('Mongo not defined (use :with_mongo helper)!')
  end

  class << self
    def with_mongo
      before :all do
        require 'ostruct'

        $mongo = OpenStruct.new.tap do |m|
          m.connection = Mongo::Connection.new
          m.db = m.connection.db MONGO_TEST_DATABASE_NAME
        end
      end
      after(:all){$mongo = nil}

      before do
        mongo.db.clear
      end
    end
  end
end