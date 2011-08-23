module Mongo::Model::Misc
  def update_timestamps
    now = Time.now.utc
    self.created_at ||= now
    self.updated_at = now
  end

  module ClassMethods
    def timestamps!
      attr_accessor :created_at, :updated_at
      before_save :update_timestamps
    end
  end
end