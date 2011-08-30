module Mongo::ObjectHelper
  #
  # CRUD
  #
  def create_with_object doc, opts = {}
    if doc.is_a? ::Mongo::Object
      doc.create_object self, opts
    else
      create_without_object doc, opts
    end
  end

  def update_with_object *args
    if args.first.is_a? ::Mongo::Object
      doc, opts = args
      opts ||= {}
      doc.update_object self, opts
    else
      update_without_object *args
    end
  end

  def save_with_object doc, opts = {}
    if doc.is_a? ::Mongo::Object
      doc.save_object self, opts
    else
      save_without_object doc, opts
    end
  end

  def destroy_with_object *args
    if args.first.is_a? ::Mongo::Object
      doc, opts = args
      opts ||= {}
      doc.destroy_object self, opts
    else
      destroy_without_object *args
    end
  end

  def create! *args
    create(*args) || raise(Mongo::Error, "can't create #{doc.inspect}!")
  end

  def update! *args
    update(*args) || raise(Mongo::Error, "can't update #{doc.inspect}!")
  end

  def save! *args
    save(*args) || raise(Mongo::Error, "can't save #{doc.inspect}!")
  end

  def destroy! *args
    destroy(*args) || raise(Mongo::Error, "can't destroy #{doc.inspect}!")
  end


  #
  # Querying
  #
  def first selector = {}, opts = {}, &block
    opts = opts.clone
    if opts.delete(:object) == false
      super selector, opts, &block
    else
      ::Mongo::Object.build super(selector, opts, &block)
    end
  end

  def each selector = {}, opts = {}, &block
    opts = opts.clone
    if opts.delete(:object) == false
      super selector, opts, &block
    else
      super selector, opts do |doc|
        block.call ::Mongo::Object.build(doc)
      end
    end
  end
end