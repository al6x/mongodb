class Mongo::Ext::Query
  class Dsl < BasicObject
    class Statement < ::Array
      def add_to hash
        operator, value = self[-2, -1]
        path = self[0..-3]

        current = hash
        path.each_with_index do |key, index|
          if index == path.size - 1
            raise "dupliate key :#{key}!" if current.include? key
            current[key] = value
          else
            raise "dupliate key :#{key}!" if current.include?(key) and !current[key].is_a?(Hash)
            current[key] ||= {}
            current = current[key]
          end
        end
        nil
      end
    end

    def initialize &block
      @statements = [Statement.new]
      block.call self
      statements.pop if statements.last.empty?
    end

    {
      :== => :==,
      :!= => :$ne,
      :<  => :$lt,
      :<= => :$lte,
      :>  => :$gt,
      :>= => :$gte,
    }.each do |ruby, mongo|
      define_method ruby do |arg|
        emit mongo
        emit arg, true
      end
    end

    def to_hash
      h = {}
      statements.each{|s| h.add_to h}
      h
    end

    protected
      attr_reader :statements

      def emit statement = nil, terminate = false
        statements.last << statement if statement
        statements << Statement.new if terminate
        nil
      end

      def method_missing m, *args, &block
        raise "invalid usage, there can be only one argument (#{args})!" if args.size > 1

        if args.empty?
          emit m
          self
        else
          emit m
          emit args.first, true
        end
      end

      def p *args
        ::Kernel.p *args
      end
  end

  def initialize collection, &block
    @collection = collection
    @hash_query = Dsl.new(&block).to_hash
  end

  def first
    collection.first to_hash
  end

  def all &block
    collection.first to_hash, &block
  end
  alias_method :each, :all

  protected
    attr_reader :collection, :hash_query
end