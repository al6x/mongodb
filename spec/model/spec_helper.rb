require 'mongo_db/model'

require 'object/spec_helper'
require 'mongo_db/model/spec'

begin
  require 'active_model'
rescue LoadError => e
  warn 'WARN: some specs require activemodel gem, will be skipped'
end