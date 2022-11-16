class UnsecuredTesting < ActiveRecord::Base
  self.table_name = "table_with_no_secured_attributes"
end
