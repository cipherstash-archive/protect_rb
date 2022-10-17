class DslTesting < ActiveRecord::Base
  self.table_name = "users_for_dsl_testing"

  has_encrypted :email
  has_encrypted :full_name
  has_encrypted :bio
  has_encrypted :dob, type: :date
  has_encrypted :updated_at, type: :date

  secure_search :dob
end
