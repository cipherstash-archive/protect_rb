class DslTesting < ActiveRecord::Base
  self.table_name = "users_for_dsl_testing"

  secure_search :dob, type: :date
end
