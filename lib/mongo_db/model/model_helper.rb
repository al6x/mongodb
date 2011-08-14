class Mongo::Ext::ModelHelper
  #
  # CRUD
  #
  def insert_with_model doc_or_docs, opts = {}
    doc_or_docs = [doc_or_docs] unless doc_or_docs.is_a?(Array)
    result = _insert_without_model doc_or_docs, opts
    result.size > 1 ? result : result.first
  end
  
  def _insert_without_model docs, opts
    result = insert_models docs do |hashes|
      r = insert_without_model hashes, opts
      r.is_a?(Array) ? r : [doc_or_docs]
    end
  end

  def update_with_model selector, document, opts = {}
    selector = convert_underscore_to_dollar_in_selector selector
    document = convert_underscore_to_dollar_in_update document

    # because :multi works only with $ operators, we need to check it
    opts = if document.keys.any?{|k| k =~ /^\$/}
      reverse_merge_defaults(opts, :safe, :multi)
    else
      reverse_merge_defaults(opts, :safe)
    end

    update_without_model selector, document, opts
  end

  def remove_with_model selector = {}, opts = {}
    selector = convert_underscore_to_dollar_in_selector selector
    remove_without_model selector, reverse_merge_defaults(opts, :safe, :multi)
  end

  def destroy *args
    remove *args
  end

  #
  # Querying
  #
  def first spec_or_object_id = nil, opts = {}
    spec_or_object_id = convert_underscore_to_dollar_in_selector spec_or_object_id if spec_or_object_id.is_a? Hash

    o = find_one spec_or_object_id, opts
    o = ::Mongo::Ext::HashHelper.symbolize o if Mongo.defaults[:symbolize]
    o
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
    selector = convert_underscore_to_dollar_in_selector selector

    cursor = nil
    begin
      cursor = find selector, reverse_merge_defaults(opts, :batch_size)
      cursor.each do |o|
        o = ::Mongo::Ext::HashHelper.symbolize o if Mongo.defaults[:symbolize]
        block.call o
      end
      nil
    ensure
      cursor.close if cursor
    end
  end

  protected
    def insert_model objects, &block
      hashes = objects.collect do      
        Mongo::Ext::ModelHelper.convert_to_hash obj
      end
      results = block.call hashes
      p results
      Mongo::Ext::ModelHelper.conv
    end
  
    def convert_underscore_to_dollar_in_selector selector
      if Mongo.defaults[:convert_underscore_to_dollar]
        selector = ::Mongo::Ext::HashHelper.convert_underscore_to_dollar_in_selector selector
      end
      selector
    end

    def convert_underscore_to_dollar_in_update update
      if Mongo.defaults[:convert_underscore_to_dollar]
        update = ::Mongo::Ext::HashHelper.convert_underscore_to_dollar_in_selector update
      end
      update
    end

    def reverse_merge_defaults opts, *keys
      h = opts.clone
      keys.each do |k|
        h[k] = Mongo.defaults[k] if Mongo.defaults.include?(k) and !h.include?(k)
      end
      h
    end
end