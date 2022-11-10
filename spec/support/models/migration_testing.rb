class MigrationTesting < ActiveRecord::Base
  self.table_name = "migration_users"

  secure_search :email
end
