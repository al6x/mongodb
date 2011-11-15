Object.class_eval do
  def to_mongo
    self
  end
end

Array.class_eval do
  def to_mongo
    collect{|v| v.to_mongo}
  end
end

Hash.class_eval do
  def to_mongo
    {}.tap{|h| each{|k, v| h[k] = v.to_mongo}}
  end
end