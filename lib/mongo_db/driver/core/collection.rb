module Mongo::Ext::Collection
  # 
  # CRUD
  #   
  def save_with_ext doc, opts = {}
    save_without_ext doc, reverse_merge_defaults(opts, :safe)
  end
  
  def insert_with_ext doc_or_docs, opts = {}
    insert_without_ext doc_or_docs, reverse_merge_defaults(opts, :safe)
  end
  
  def update_with_ext selector, document, opts = {}
    # because :multi works only with $ operators, we need to check it
    opts = if document.keys.any?{|k| k =~ /^\$/}      
      reverse_merge_defaults(opts, :safe, :multi)
    else
      reverse_merge_defaults(opts, :safe)
    end
    
    update_without_ext selector, document, opts
  end

  def remove_with_ext selector = {}, opts = {}
    remove_without_ext selector, reverse_merge_defaults(opts, :safe, :multi)
  end

  def destroy *args
    remove *args
  end
  
  # 
  # Querying
  # 
  def first *args
    o = find_one *args
    ::Mongo::Ext::HashHelper.unmarshal o
  end
  
  def all *args, &block
    if block
      each *args, &block
    else
      list = []
      each(*args){|o| list << o}
      list
    end
  end
  
  def each selector = {}, opts = {}, &block
    cursor = nil
    begin
      cursor = find selector, reverse_merge_defaults(opts, :batch_size)
      cursor.each do |o|
        o = ::Mongo::Ext::HashHelper.unmarshal o
        block.call o
      end
      nil
    ensure
      cursor.close if cursor
    end
  end
  
  protected
    def reverse_merge_defaults opts, *keys
      h = opts.clone
      keys.each do |k|
        h[k] = Mongo.defaults[k] if Mongo.defaults.include?(k) and !h.include?(k)
      end
      h
    end
end