module Mongo::Model::Crud
  def save opts = {}
    with_collection opts do |collection, opts|
      collection.save self, opts
    end
  end

  def save! *args
    save(*args) || raise(Mongo::Error, "can't save #{self.inspect}!")
  end

  def destroy opts = {}
    with_collection opts do |collection, opts|
      collection.destroy self, opts
    end
  end

  def destroy! *args
    destroy(*args)|| raise(Mongo::Error, "can't destroy #{self.inspect}!")
  end

  protected
    def with_collection opts, &block
      opts = opts.clone
      collection = opts.delete(:collection) || self.class.collection
      block.call collection, opts
    end
end