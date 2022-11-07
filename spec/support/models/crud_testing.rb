class CrudTesting < ActiveRecord::Base
  self.table_name = "users_for_crud_testing"

  secure_search :email
  secure_search :dob, type: :date
  secure_search :last_login, type: :datetime
  secure_search :age, type: :integer
  secure_search :verified, type: :boolean
  secure_search :latitude, type: :float
end
