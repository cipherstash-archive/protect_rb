class PlaintextTesting < ActiveRecord::Base
  self.table_name = "plaintext_users"

  secure_search :dob, type: :date
  secure_search :last_login, type: :datetime
  secure_search :verified, type: :boolean
  secure_search :latitude, type: :float
end
