class CrudTesting < ActiveRecord::Base
  self.table_name = "users_for_crud_testing"

  has_encrypted :email
  has_encrypted :dob, type: :date
  has_encrypted :last_login, type: :datetime
  has_encrypted :age, type: :integer
  has_encrypted :verified, type: :boolean
  has_encrypted :latitude, type: :float

  secure_search :email
  secure_search :dob
  secure_search :last_login
  secure_search :age
  secure_search :verified
  secure_search :latitude
end
