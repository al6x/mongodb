MONGO_TEST_DATABASE = 'default_test'

rspec do    
  def mongo
    $mongo || raise('Mongo not defined (use :with_mongo helper)!')
  end
  
  def clear_mongo name = MONGO_TEST_DATABASE
    mongo.db.collection_names.each do |name|
      next if name =~ /^system\./
      mongo.db.collection(name).drop
    end
  end
  
  class << self
    def with_mongo
      require 'ostruct'
    
      before :all do
        $mongo = OpenStruct.new.tap do |m|
          m.connection = Mongo::Connection.new
          m.db = m.connection.db MONGO_TEST_DATABASE
        end
      end      
      after(:all){$mongo = nil}
    
      before do        
        clear_mongo        
      end
    end
  end
end