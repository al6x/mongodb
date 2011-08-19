# namespace :db do
#   desc "Migrate Database"
#   task migrate: :migration_evnironment do
#     require 'mongo_migration'
#
#     database_name = (ENV['d'] || ENV['database'] || :default).to_sym
#     version = ENV['v'] || ENV['version']
#
#     if version.blank?
#       size = Mongo.migration.definitions[database_name].size
#       highest_defined_version = size == 0 ? 0 : size - 1
#       version = highest_defined_version
#     else
#       version = version.to_i
#     end
#
#     Mongo.migration.update version, database_name
#   end
# end