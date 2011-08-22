module Mongo::Model::Assignment
  def set attributes
    attributes.each do |k, v|
      self.send "#{k}=", v
    end
    self
  end

  # def set attributes
  #   values.each do |k, v|
  #     self.send "#{k}=", v
  #   end
  #   return self
  # end
end