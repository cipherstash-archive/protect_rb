class PlaintextTesting < ActiveRecord::Base
  self.table_name = "plaintext_users"


  has_encrypted :dob, type: :date
  has_encrypted :last_login, type: :datetime
  has_encrypted :verified, type: :boolean
  has_encrypted :latitude, type: :float


  secure_search :dob
  secure_search :last_login
  secure_search :verified
  secure_search :latitude
end
