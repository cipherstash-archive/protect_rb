class CreateUsersTableForValidatesTesting < ActiveRecord::Migration[RAILS_VERSION]
  def change
    create_table :users_for_validates_testing do |t|
      t.text :email_ciphertext
      t.column :email_secure_search, :ore_64_8_v1_text
    end
  end
end
