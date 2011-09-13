# Example of [Data Migration][migration] with Rake Task.

# Including `db:migration` task.
require 'mongo/migration/tasks'

# The `db:migration` task depends on non-existing `db:migration_evnironment` task.
# You need to define this task and perform there all preparations needed
# for migration.
#
# Let's suppose that You are using some framework (Rails for example) and it
# has task `:environment` for preparing framework environment.
#
# We make our `db:migration_evnironment` dependent on the framework's `:environment`.
# So, Your framework will be properly initialized and available in migration scripts.
desc "Internal task to prepare migration environment"
task 'db:migration_evnironment' => 'environment' do
  require 'mongo/migration'

  # Usually migrations are defined as files in some folder, loading it.
  Dir["./db/**/*.rb"].each{|f| require f.sub(/\.rb$/, '')}
end

# Now You can migrate Your database (if You omit version the highest
# availiable will be choosen).
#
#     rake db:migrate d=my_database_name v=10

# [migration]: migration.html