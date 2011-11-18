module Mongo::CollectionHelper
  # CRUD.

  def create_with_object doc, options = {}
    if doc.is_a? ::Mongo::Object
      doc.create_object self, options
    else
      create_without_object doc, options
    end
  end

  def update_with_object *args
    if args.first.is_a? ::Mongo::Object
      doc, options = args
      options ||= {}
      doc.update_object self, options
    else
      update_without_object *args
    end
  end

  def save_with_object doc, options = {}
    if doc.is_a? ::Mongo::Object
      doc.save_object self, options
    else
      save_without_object doc, options
    end
  end

  def delete_with_object *args
    if args.first.is_a? ::Mongo::Object
      doc, options = args
      options ||= {}
      doc.delete_object self, options
    else
      delete_without_object *args
    end
  end

  def create! *args
    create(*args) || raise(Mongo::Error, "can't create #{args.inspect}!")
  end

  def update! *args
    update(*args) || raise(Mongo::Error, "can't update #{args.inspect}!")
  end

  def save! *args
    save(*args) || raise(Mongo::Error, "can't save #{args.inspect}!")
  end

  def delete! *args
    delete(*args) || raise(Mongo::Error, "can't delete #{args.inspect}!")
  end

  # Querying.

  def first selector = {}, options = {}, &block
    options = options.clone
    if options.delete(:object) == false
      super selector, options, &block
    else
      ::Mongo::Object.build super(selector, options, &block)
    end
  end

  def each selector = {}, options = {}, &block
    options = options.clone
    if options.delete(:object) == false
      super selector, options, &block
    else
      super selector, options do |doc|
        block.call ::Mongo::Object.build(doc)
      end
    end
  end
end