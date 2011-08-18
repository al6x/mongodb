module Mongo::ObjectHelper
  #
  # CRUD
  #
  def save_with_object doc, opts = {}
    if doc.is_a? Hash
      save_without_object doc, opts
    else
      ::Mongo::ObjectSerializer.new(doc).save opts, self
    end
  end

  def insert_with_object args, opts = {}
    if args.is_a?(Hash) or args.is_a?(Array)
      insert_without_object args, opts
    else
      ::Mongo::ObjectSerializer.new(args).insert opts, self
    end
  end

  def update_with_object selector, doc, opts = {}
    if doc.is_a?(Hash)
      update_without_object selector, doc, opts
    else
      raise "can't use update selector with object (#{selector}, {#{doc}})!" unless selector == nil
      ::Mongo::ObjectSerializer.new(doc).update opts, self
    end
  end

  def remove_with_object arg = {}, opts = {}
    if arg.is_a? Hash
      remove_without_object arg, opts
    else
      ::Mongo::ObjectSerializer.new(arg).remove opts, self
    end
  end


  #
  # Querying
  #
  def first *args, &block
    doc = super *args, &block
    ::Mongo::ObjectSerializer.build(doc)
  end

  def each *args, &block
    super *args do |doc|
      obj = ::Mongo::ObjectSerializer.build(doc)
      block.call obj
    end
    nil
  end
end