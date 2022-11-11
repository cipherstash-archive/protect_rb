class UniquenessTesting < ActiveRecord::Base
  self.table_name = "users_for_uniqueness_testing"

  secure_search :example_validation, type: :string
  validates :example_validation, uniqueness: true
end
