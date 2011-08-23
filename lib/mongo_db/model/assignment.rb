module Mongo::Model::Assignment
  class Dsl < BasicObject
    def initialize
      @attributes = {}
    end

    def self.const_missing name
      # BasicObject doesn't have access to any constants like String, Symbol, ...
      ::Object.const_get name
    end

    def to_h; attributes end

    protected
      attr_reader :attributes

      def method_missing attribute_name, type, mass_assignment = false
        attribute_name.must_be.a Symbol
        type.must.respond_to :cast
        attributes[attribute_name] = [type, mass_assignment]
      end
  end

  def set attributes, options = {}
    if rules = self.class._assignment
      force = options[:force]
      attributes.each do |n, v|
        n = n.to_sym
        type, mass_assignment = rules[n]
        if type and (mass_assignment or force)
          v = type.cast(v)
          send "#{n}=", v
        end
      end
    else
      attributes.each{|n, v| send "#{n}=", v}
    end
    self
  end

  def set! attributes, options = {}
    set attributes, options.merge(force: true)
  end

  module ClassMethods
    inheritable_accessor :_assignment, nil

    def assignment &block
      dsl = ::Mongo::Model::Assignment::Dsl.new
      dsl.instance_eval &block
      self._assignment = (_assignment || {}).merge dsl.to_h
    end
  end
end